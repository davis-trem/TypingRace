extends Control
@onready var solo_button: Button = $Background/InformationContainer/VBoxContainer/VBoxContainer/SoloButton
@onready var solo_options: MarginContainer = $Background/InformationContainer/VBoxContainer/VBoxContainer/SoloOptions

var focused_control := solo_button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	solo_button.grab_focus()


func _on_solo_button_pressed() -> void:
	solo_options.visible = not solo_options.visible


func _on_solo_1_button_pressed() -> void:
	SceneManager.initialize_test(SceneManager.TEST_TYPE.SOLO1)


func _on_solo_2_button_pressed() -> void:
	SceneManager.initialize_test(SceneManager.TEST_TYPE.SOLO2)


func _on_solo_3_button_pressed() -> void:
	SceneManager.initialize_test(SceneManager.TEST_TYPE.SOLO3)


func _on_options_button_pressed() -> void:
	SceneManager.change_screen(SceneManager.SCREEN_OPTIONS)
