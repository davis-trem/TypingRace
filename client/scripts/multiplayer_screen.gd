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
	
	Server.joined_room_and_waiting.connect(_on_joined_room_and_waiting)
	Server.room_ready_to_start.connect(_on_room_ready_to_start)
	
	Server.connect_to_server()


func _process(delta: float) -> void:
	ellipsis_time += delta
	
	if connecting and ellipsis_time >= 0.7:
		status.text = status_text + '.'.repeat(status_ellipsis)
		ellipsis_time = 0.0
		status_ellipsis = wrapi(status_ellipsis + 1, 0, 4)


func _on_connected_to_server() -> void:
	prints('connection success')
	status_text = 'Looking for opponent'
	Server.request_join_random_room()


func _on_connection_failed() -> void:
	prints('connection failed')
	status_text = 'Unable to connect to server'
	status.text = status_text
	connecting = false


func _on_joined_room_and_waiting(room_id: int) -> void:
	prints('room_successfully_created', room_id)


func _on_room_ready_to_start(room_id: int, peer_ids: Array) -> void:
	prints('room_filled_and_ready', room_id, peer_ids)
	status_text = 'Opponent found!'
	status.text = status_text
	connecting = false
	continue_button.disabled = false


func _on_back_button_pressed() -> void:
	if Server.multiplayer_peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTED:
		Server.disconnect_from_server()
	SceneManager.change_screen(SceneManager.SCREEN_MAIN_MENU)


func _on_continue_button_pressed() -> void:
	Server.confirm_ready_for_test()
	status_text = 'Waiting for opponent to confirm ready'
	status.text = status_text
