extends Control

const _5_CETA_MONO_FONT = preload('res://fonts/5ceta_mono.ttf')

@onready var options_container: VBoxContainer = $Background/InformationContainer/VBoxContainer/OptionsContainer
@onready var sound_fx_button: CheckButton = $Background/InformationContainer/VBoxContainer/HBoxContainer/SoundFxButton
@onready var back_button: Button = $Background/InformationContainer/VBoxContainer/VBoxContainer/BackButton

const ACTIONS = [
	'toggle_zoom',
	'toggle_virtual_keyboard',
	'toggle_exit_menu',
]

var changing_shortcut := false
var updated_button : Button
var updated_action : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sound_fx_button.grab_focus()
	sound_fx_button.button_pressed = SceneManager.enable_sound_fx
	
	back_button.pressed.connect(func (): SceneManager.change_screen(SceneManager.SCREEN_MAIN_MENU))
	
	for action: String in ACTIONS:
		if not InputMap.has_action(action):
			return
		
		var row := HBoxContainer.new()
		
		var label := Label.new()
		label.text = action.capitalize()
		label.add_theme_font_override('font', _5_CETA_MONO_FONT)
		label.add_theme_font_size_override('size', 20)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var button := Button.new()
		button.text = InputMap.action_get_events(action)[0].as_text()
		button.flat = true
		button.add_theme_font_override('font', _5_CETA_MONO_FONT)
		button.add_theme_color_override('font_focus_color', Color(0, 190, 0))
		button.pressed.connect(func (): _on_short_cut_button_pressed(button, action))
		
		row.add_child(label)
		row.add_child(button)
		options_container.add_child(row)


func _unhandled_input(event: InputEvent) -> void:
	if updated_button and updated_action and event.pressed:
		InputMap.action_erase_events(updated_action)
		InputMap.action_add_event(updated_action, event)
		updated_button.text = InputMap.action_get_events(updated_action)[0].as_text()
		updated_button = null
		updated_action = ''
		changing_shortcut = false
		


func _on_short_cut_button_pressed(button: Button, action: String):
	changing_shortcut = true
	updated_button = button
	updated_action = action
	set_process_unhandled_input(true)
	button.text = '... Awaiting input ...'


func _on_sound_fx_button_toggled(toggled_on: bool) -> void:
	SceneManager.enable_sound_fx = toggled_on
