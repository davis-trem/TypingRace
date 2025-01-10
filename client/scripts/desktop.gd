extends Node3D

@onready var keyboard_anim_player: AnimationPlayer = $MechanicalKeyboard/AnimationPlayer

# I named some the animations in the keyboard model different from Godot's
const key_code_to_keyboard = {
	'Escape': 'Esc',
	'Slash': 'Forwardslash',
	'BackSlash': 'Backslash',
	'BracketLeft': 'Bracket_open',
	'BracketRight': 'Bracket_close',
	'Apostrophe': 'Quote',
}

func _on_input_manager_key_event(key: String, is_press: bool) -> void:
	var anim_name := _get_animation_name(key)
	if is_press:
		keyboard_anim_player.play(anim_name)
	else:
		keyboard_anim_player.play_backwards(anim_name)


func _get_animation_name(key: String) -> String:
	return '{0}_pressed'.format([key_code_to_keyboard.get(key, key)])
