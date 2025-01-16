extends Control

@onready var cursor: ColorRect = $MarginContainer/VBoxContainer/RichTextLabel/Cursor
@onready var rich_text_label: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel

const CHAR_WIDTH = 22.5

var rich_text_regex = RegEx.new()
var char_pos = 0
var char_line_and_positions := {}

func _ready() -> void:
	rich_text_regex.compile(r"\[color=.*?\].\[/color\]|.")


func handle_key_event(typed_char: String, is_pressed: bool) -> void:
	(cursor.material as ShaderMaterial).set_shader_parameter('should_blink', not is_pressed)
	
	if typed_char == '' or len(rich_text_label.text) == 0 or char_pos == len(rich_text_label.text) - 1:
		return
		
	if is_pressed:
		var chars := _get_rich_text_chars()
		if chars[char_pos] != typed_char:
			rich_text_label.text = (
				''.join(chars.slice(0, char_pos))
				+ '{0}{1}{2}'.format(['[color=red]', chars[char_pos], '[/color]'])
				+ ''.join(chars.slice(char_pos + 1))
			)


func _get_rich_text_chars() -> Array:
	var matches = rich_text_regex.search_all(rich_text_label.text)
	return matches.map(func (m): return m.get_string())


func on_char_pos_updated(pos: int) -> void:
	var chars := _get_rich_text_chars()
	rich_text_label.text = (
		''.join(chars.slice(0, pos))
		+ chars[pos].replace('[color=red]', '').replace('[/color]', '')
		+ ''.join(chars.slice(pos + 1))
	)
	
	var line = rich_text_label.get_character_line(pos)
	rich_text_label.scroll_to_line(line)
	var char_line_index = char_line_and_positions[line].find(pos)
	cursor.position.x = CHAR_WIDTH * char_line_index
	
	char_pos = pos


func set_test_copy(copy: String) -> void:
	rich_text_label.text = copy
	char_pos = 0
	char_line_and_positions = {}
	for index in range(len(rich_text_label.text)):
		var line := rich_text_label.get_character_line(index)
		var positions: Array = char_line_and_positions.get(line, [])
		positions.append(index)
		char_line_and_positions[line] = positions
