extends Node3D

const typing_screen_scene = preload('res://scenes/typing_screen.tscn')

@onready var keyboard_anim_player: AnimationPlayer = $MechanicalKeyboard/AnimationPlayer
@onready var camera_animation_player: AnimationPlayer = $CameraAnimationPlayer
@onready var sub_viewport: SubViewport = $SubViewport

var typing_screen: Control

# I named some the animations in the keyboard model different from Godot's
const key_code_to_keyboard = {
	'Escape': 'Esc',
	'Slash': 'Forwardslash',
	'BackSlash': 'Backslash',
	'BracketLeft': 'Bracket_open',
	'BracketRight': 'Bracket_close',
	'Apostrophe': 'Quote',
	'CapsLock': 'Caps',
}

var in_wide_view := true

func _input(event: InputEvent) -> void:
	sub_viewport.push_input(event)


func _on_input_manager_key_event(key: String, typed_char: String, is_press: bool) -> void:
	var anim_name := _get_animation_name(key)
	if is_press:
		keyboard_anim_player.play(anim_name)
	else:
		keyboard_anim_player.play_backwards(anim_name)
	
	if typing_screen:
		typing_screen.handle_key_event(typed_char, is_press)


func _get_animation_name(key: String) -> String:
	return '{0}_pressed'.format([key_code_to_keyboard.get(key, key)])


func _on_input_manager_test_copy_loaded(copy: String) -> void:
	typing_screen = typing_screen_scene.instantiate()
	var screens := sub_viewport.get_children()
	sub_viewport.remove_child(screens[0])
	sub_viewport.add_child(typing_screen)
	typing_screen.set_test_copy(copy)


func _on_input_manager_char_pos_updated(pos: int) -> void:
	if typing_screen:
		typing_screen.on_char_pos_updated(pos)


func _on_input_manager_test_time_updated(time: int, wpm: float, accuracy: float) -> void:
	if typing_screen:
		typing_screen.update_test_time(time, wpm, accuracy)


func _on_toggle_zoom_button_pressed() -> void:
	if in_wide_view:
		in_wide_view = false
		camera_animation_player.play('wide_view_to_close_view')
	else:
		in_wide_view = true
		camera_animation_player.play_backwards('wide_view_to_close_view')
