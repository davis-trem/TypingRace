extends Control
@onready var solo_button: Button = $Background/InformationContainer/VBoxContainer/VBoxContainer/SoloButton
@onready var solo_options: MarginContainer = $Background/InformationContainer/VBoxContainer/VBoxContainer/SoloOptions
@onready var muliplayer_options: MarginContainer = $Background/InformationContainer/VBoxContainer/VBoxContainer/MuliplayerOptions

var focused_control := solo_button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	solo_button.grab_focus()


func _on_solo_button_pressed() -> void:
	muliplayer_options.hide()
	solo_options.visible = not solo_options.visible


func _on_solo_1_button_pressed() -> void:
	SceneManager.initialize_test(SceneManager.TEST_TYPE.SOLO1)


func _on_solo_2_button_pressed() -> void:
	SceneManager.initialize_test(SceneManager.TEST_TYPE.SOLO2)


func _on_solo_3_button_pressed() -> void:
	SceneManager.initialize_test(SceneManager.TEST_TYPE.SOLO3)


func _on_options_button_pressed() -> void:
	SceneManager.change_screen(SceneManager.SCREEN_OPTIONS)


func _on_multiplayer_button_pressed() -> void:
	solo_options.hide()
	muliplayer_options.visible = not muliplayer_options.visible


func _on_join_random_button_pressed() -> void:
	SceneManager.change_screen(
		SceneManager.SCREEN_MULTIPLAYER,
		func(screen: MultiplayerScreen): screen.multiplayer_type = SceneManager.MULTIPLAYER_TYPE.JOIN_RANDOM
	)


func _on_private_room_button_pressed() -> void:
	SceneManager.change_screen(
		SceneManager.SCREEN_MULTIPLAYER,
		func(screen: MultiplayerScreen): screen.multiplayer_type = SceneManager.MULTIPLAYER_TYPE.PRIVATE_ROOM
	)
