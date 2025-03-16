extends Node3D

const popup_menu_scene = preload('res://scenes/popup_menu.tscn')
const loading_screen_scene = preload('res://scenes/loading_screen.tscn')
const ZOOM_IN_ICON = preload('res://assets/zoom_in_icon.png')
const ZOOM_OUT_ICON = preload('res://assets/zoom_out_icon.png')

@onready var keyboard_anim_player: AnimationPlayer = $MechanicalKeyboard/AnimationPlayer
@onready var camera_animation_player: AnimationPlayer = $CameraAnimationPlayer
@onready var sub_viewport: SubViewport = $SubViewport
@onready var toggle_zoom_button: Button = $'../MarginContainer/HBoxContainer/ToggleZoomButton'

var typing_screen: Control
var popup_menu: Control

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
var is_popup_menu_open := false


func _ready() -> void:
	SceneManager.retry_test.connect(_on_retry_test)
	SceneManager.loading_new_screen.connect(_on_loading_new_screen)
	SceneManager.screen_loaded.connect(_on_screen_loaded)


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
	typing_screen.set_test_copy(copy)
	typing_screen.show()
	SceneManager.loading_complete.emit()


func _on_input_manager_char_pos_updated(pos: int) -> void:
	if typing_screen:
		typing_screen.on_char_pos_updated(pos)


func _on_input_manager_test_time_updated(time: int, wpm: float, accuracy: float) -> void:
	if typing_screen:
		typing_screen.update_test_time(time, wpm, accuracy)
	
	if time == 0:
		if popup_menu == null:
			popup_menu = popup_menu_scene.instantiate()
			sub_viewport.add_child(popup_menu)
		popup_menu.description.text = 'WPM: {0}\nAccuracy: {1}%\nRetry?'.format([
			roundi(wpm),
			roundi(accuracy * 100)
		])
		popup_menu.yes_button.pressed.connect(_on_accept_retry)
		popup_menu.no_button.pressed.connect(_on_deny_retry)


func _on_accept_retry() -> void:
	SceneManager.retry_test.emit()


func _on_deny_retry() -> void:
	SceneManager.change_screen(SceneManager.SCREEN_MAIN_MENU)


func _on_retry_test() -> void:
	if popup_menu:
		sub_viewport.remove_child(popup_menu)
		popup_menu.queue_free()
		popup_menu = null
	
	if typing_screen:
		typing_screen.reset_test()


func _on_loading_new_screen(new_screen_path: String, on_load_complete: Callable) -> void:
	for node in sub_viewport.get_children():
		node.queue_free()
	popup_menu = null
	
	var loading_screen := loading_screen_scene.instantiate()
	loading_screen.new_screen_path = new_screen_path
	loading_screen.on_load_complete = on_load_complete
	sub_viewport.add_child(loading_screen)


func _on_screen_loaded(screen: Node) -> void:
	if screen is TypingScreen:
		typing_screen = screen
	else:
		typing_screen = null
		screen.show()


func _on_toggle_zoom_button_pressed() -> void:
	if in_wide_view:
		in_wide_view = false
		camera_animation_player.play('wide_view_to_close_view')
		toggle_zoom_button.icon = ZOOM_OUT_ICON
	else:
		in_wide_view = true
		camera_animation_player.play_backwards('wide_view_to_close_view')
		toggle_zoom_button.icon = ZOOM_IN_ICON


func _on_input_manager_toggle_popup_menu(description: String, accept: Callable, deny: Callable) -> void:
	if popup_menu:
		sub_viewport.remove_child(popup_menu)
		popup_menu.queue_free()
		popup_menu = null
	else:
		popup_menu = popup_menu_scene.instantiate()
		sub_viewport.add_child(popup_menu)
		popup_menu.description.text = description
		popup_menu.no_button.pressed.connect(deny)
		popup_menu.yes_button.pressed.connect(accept)
