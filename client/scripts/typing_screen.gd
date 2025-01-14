extends Control

@onready var cursor: ColorRect = $MarginContainer/VBoxContainer/RichTextLabel/Cursor
@onready var rich_text_label: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel

const CHAR_WIDTH = 22.5

var rich_text_regex = RegEx.new()
var char_pos = 0

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
			(cursor.material as ShaderMaterial).set_shader_parameter('mistake_made', true)
			return
		
		(cursor.material as ShaderMaterial).set_shader_parameter('mistake_made', false)


func _get_rich_text_chars() -> Array:
	var matches = rich_text_regex.search_all(rich_text_label.text)
	return matches.map(func (m): return m.get_string())


func on_char_pos_updated(pos: int) -> void:
	cursor.position.x += CHAR_WIDTH
	var current_line := rich_text_label.get_character_line(pos)
	if current_line != rich_text_label.get_character_line(pos - 1):
		rich_text_label.scroll_to_line(current_line)
		cursor.position.x = 0;
	
	char_pos = pos


func set_test_copy(copy: String) -> void:
	rich_text_label.text = copy


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	rich_text_label.text = body.get_string_from_utf8()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
