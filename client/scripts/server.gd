extends Node

var multiplayer_peer := ENetMultiplayerPeer.new()
const host := '127.0.0.1'
const port := 1909
var room_id := ''
var players: Dictionary[int, int] = {} # { [peer_id: int]: instance_id: int }

func connect_to_server() -> void:
	print('connecting to server')
	multiplayer_peer.create_client(host, port)
	multiplayer_peer.get_peer(1).set_timeout(0, 0, 3000) # attempt to ping server
	multiplayer.multiplayer_peer = multiplayer_peer


func disconnect_from_server() -> void:
	print('disconnecting from server')
	multiplayer_peer.disconnect_peer(1)
	multiplayer_peer.close()
	multiplayer.multiplayer_peer = null


func request_join_random_room():
	join_random_room.rpc_id(1)


######### Server methods #########
@rpc('any_peer')
func join_random_room():
	pass
