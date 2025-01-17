extends Node3D

@onready var keyboard_anim_player: AnimationPlayer = $MechanicalKeyboard/AnimationPlayer
@onready var typing_screen: Control = $SubViewport/TypingScreen

# I named some the animations in the keyboard model different from Godot's
const key_code_to_keyboard = {
	'Escape': 'Esc',
	'Slash': 'Forwardslash',
	'BackSlash': 'Backslash',
	'BracketLeft': 'Bracket_open',
	'BracketRight': 'Bracket_close',
	'Apostrophe': 'Quote',
}


func _on_input_manager_key_event(key: String, typed_char: String, is_press: bool) -> void:
	var anim_name := _get_animation_name(key)
	if is_press:
		keyboard_anim_player.play(anim_name)
	else:
		keyboard_anim_player.play_backwards(anim_name)
	
	typing_screen.handle_key_event(typed_char, is_press)


func _get_animation_name(key: String) -> String:
	return '{0}_pressed'.format([key_code_to_keyboard.get(key, key)])


func _on_input_manager_test_copy_loaded(copy: String) -> void:
	typing_screen.set_test_copy(copy)


func _on_input_manager_char_pos_updated(pos: int) -> void:
	typing_screen.on_char_pos_updated(pos)


func _on_input_manager_test_time_updated(time: int, wpm: float, accuracy: float) -> void:
	typing_screen.update_test_time(time, wpm, accuracy)
