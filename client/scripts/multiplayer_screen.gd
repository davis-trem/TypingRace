class_name MultiplayerScreen
extends Control

@onready var title: Label = $Background/InformationContainer/VBoxContainer/VBoxContainer/Title
@onready var continue_button: Button = $Background/InformationContainer/VBoxContainer/VBoxContainer/VBoxContainer/ContinueButton
@onready var status: Label = $Background/InformationContainer/VBoxContainer/VBoxContainer/Status

var multiplayer_type: SceneManager.MULTIPLAYER_TYPE
var connecting := true
var status_ellipsis := 0
var ellipsis_time := 0.0
var status_text := 'Connecting'


func _ready() -> void:
	continue_button.grab_focus()
	title.text = 'Join Random'\
		if multiplayer_type == SceneManager.MULTIPLAYER_TYPE.JOIN_RANDOM\
		else 'Private Room'
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
	Server.connect_to_server()


func _process(delta: float) -> void:
	ellipsis_time += delta
	
	if connecting and ellipsis_time >= 0.7:
		status.text = status_text + '.'.repeat(status_ellipsis)
		ellipsis_time = 0.0
		status_ellipsis = wrapi(status_ellipsis + 1, 0, 4)


func _on_connected_to_server() -> void:
	status_text = 'Looking for opponent'
	Server.request_join_random_room()


func _on_connection_failed() -> void:
	status_text = 'Unable to connect to server'
	connecting = false


func _on_back_button_pressed() -> void:
	Server.disconnect_from_server()
	SceneManager.change_screen(SceneManager.SCREEN_MAIN_MENU)


func _on_continue_button_pressed() -> void:
	pass # Replace with function body.
