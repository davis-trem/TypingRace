extends Node

var multiplayer_peer := ENetMultiplayerPeer.new()
const port := 1909
var rooms: Dictionary[int, Dictionary] = {} # {[room_id]: { 'players': { [peer_id]: {} } }}

func _ready() -> void:
	_start_server()


func _start_server():
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	print('Server running...')
	
	multiplayer_peer.peer_connected.connect(_on_peer_connected)
	multiplayer_peer.peer_disconnected.connect(_on_peer_disconnected)


func _on_peer_connected(peer_id: int):
	print('peer {0} connected'.format([peer_id]))


func _on_peer_disconnected(peer_id: int):
	print('peer {0} disconnected'.format([peer_id]))
	for room_id in rooms:
		if peer_id in rooms[room_id]['players']:
			rooms[room_id]['players'].erase(peer_id)
			return


@rpc('any_peer')
func join_random_room():
	print('requested to join random room')
	var peer_id := multiplayer.get_remote_sender_id()
	
	# Find room with waiting player
	for room_id in rooms:
		if rooms[room_id]['players'].size() == 1:
			rooms[room_id]['players'][peer_id] = {}
			# Notify room joined and ready
			for id in rooms[room_id]['players'].keys():
				room_filled_and_ready.rpc_id(id, room_id, rooms[room_id]['players'].keys())
				prints('room_filled_and_ready', id, room_id, rooms[room_id]['players'].keys())
			return
	
	# Create room if none waiting
	var room_id := multiplayer_peer.generate_unique_id()
	while rooms.has(room_id):
		room_id = multiplayer_peer.generate_unique_id()
	rooms[room_id] = { 'players': { peer_id: {} } }
	# Notify room joined and waiting
	room_successfully_created.rpc_id(peer_id, room_id)
	prints('room_successfully_created', peer_id, room_id)


######### Client methods #########
@rpc('authority')
func room_successfully_created(_room_id: int):
	pass


@rpc('authority')
func room_filled_and_ready(_room_id: int, _peer_ids: Array):
	pass
