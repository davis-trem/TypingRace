extends Control

@onready var label: Label = $MarginContainer/VBoxContainer/ScrollContainer/Label
@onready var cursor: ColorRect = $MarginContainer/VBoxContainer/ScrollContainer/Label/Cursor
@onready var scroll_container: ScrollContainer = $MarginContainer/VBoxContainer/ScrollContainer

var char_pos = 0

func handle_key_event(typed_char: String, is_pressed: bool) -> void:
	(cursor.material as ShaderMaterial).set_shader_parameter('should_blink', not is_pressed)
	
	if typed_char == '' or len(label.text) == 0 or char_pos == len(label.text) - 1:
		return
		
	if is_pressed:
		if label.text[char_pos] != typed_char:
			(cursor.material as ShaderMaterial).set_shader_parameter('mistake_made', true)
			return
		
		(cursor.material as ShaderMaterial).set_shader_parameter('mistake_made', false)
		


func on_char_pos_updated(pos: int) -> void:
	char_pos = pos
	var char_bounds := label.get_character_bounds(char_pos)
		
	if char_bounds.position.y != 0: # scroll down if cursor is on next line
		scroll_container.scroll_vertical = char_bounds.position.y
		char_bounds = label.get_character_bounds(char_pos)
	
	if ( # account for space at end of line
		label.text.unicode_at(char_pos) == 32
		and label.get_character_bounds(char_pos + 1).position.y != char_bounds.position.y
	):
		var prev_char_bounds := label.get_character_bounds(char_pos - 1)
		cursor.position = Vector2(
			prev_char_bounds.position.x + prev_char_bounds.size.x,
			prev_char_bounds.position.y
		)
	else:
		cursor.position = char_bounds.position


func set_test_copy(copy: String) -> void:
	label.text = copy
	var char_bounds := label.get_character_bounds(char_pos)
	cursor.size = char_bounds.size
	cursor.position = char_bounds.position


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	label.text = body.get_string_from_utf8()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
