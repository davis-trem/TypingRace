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
			rooms[room_id]['players'][peer_id] = {
				'ready': false,
				'wpm': 0.0,
				'accuracy': 0.0
			}
			# Notify room joined and ready
			for id in rooms[room_id]['players'].keys():
				room_filled_and_ready.rpc_id(id, room_id, rooms[room_id]['players'].keys())
				prints('room_filled_and_ready', id, room_id, rooms[room_id]['players'].keys())
			return
	
	# Create room if none waiting
	var room_id := multiplayer_peer.generate_unique_id()
	while rooms.has(room_id):
		room_id = multiplayer_peer.generate_unique_id()
	rooms[room_id] = { 
		'players': {
			peer_id: {
				'ready': false,
				'wpm': 0.0,
				'accuracy': 0.0
			}
		} 
	}
	# Notify room joined and waiting
	room_successfully_created.rpc_id(peer_id, room_id)
	prints('room_successfully_created', peer_id, room_id)


@rpc('any_peer')
func ready_for_test(room_id: int):
	var peer_id := multiplayer.get_remote_sender_id()
	prints(peer_id, 'ready for test')
	rooms[room_id]['players'][peer_id]['ready'] = true
	# Check if other player is ready
	for other_peer_id in rooms[room_id]['players']:
		if peer_id != other_peer_id and rooms[room_id]['players'][other_peer_id]['ready']:
			# Notify all players to init test
			for id in rooms[room_id]['players']:
				all_players_ready.rpc_id(id)
			return


@rpc('any_peer')
func start_test(room_id: int):
	prints('start test', room_id)
	rooms[room_id]['test_time'] = 60
	rooms[room_id]['timer'] = Timer.new()
	add_child(rooms[room_id]['timer'])
	(rooms[room_id]['timer'] as Timer).one_shot = false
	(rooms[room_id]['timer'] as Timer).wait_time = 1
	(rooms[room_id]['timer'] as Timer).timeout.connect(func (): _on_test_timer_one_sec_timeout(room_id))
	(rooms[room_id]['timer'] as Timer).start()
	for peer_id in rooms[room_id]['players']:
		test_has_started.rpc_id(peer_id)


@rpc('any_peer')
func on_test_key_input(
	room_id: int,
	char_entries: Array,
	total_entries: int,
	total_errors: int,
):
	var peer_id := multiplayer.get_remote_sender_id()
	var wpm_and_accuracy := _calculate_wpm_and_accuracy(
		char_entries,
		rooms[room_id]['test_time'],
		total_entries,
		total_errors
	)
	rooms[room_id]['players'][peer_id]['wpm'] = wpm_and_accuracy[0]
	rooms[room_id]['players'][peer_id]['accuracy'] = wpm_and_accuracy[1]
	update_stats.rpc_id(peer_id, rooms[room_id]['test_time'], rooms[room_id]['players'])


func _on_test_timer_one_sec_timeout(room_id: int):
	rooms[room_id]['test_time'] -= 1
	
	for peer_id in rooms[room_id]['players']:
		update_stats.rpc_id(peer_id, rooms[room_id]['test_time'], rooms[room_id]['players'])
	if rooms[room_id]['test_time'] == 0:
		(rooms[room_id]['timer'] as Timer).queue_free()
		for peer_id in rooms[room_id]['players']:
			test_time_ended.rpc_id(peer_id)


func _calculate_wpm_and_accuracy(
	char_entries: Array,
	test_time: int,
	total_entries: int,
	total_errors: int,
) -> Array[float]:
	var words_typed := len(char_entries) / 5
	var errors := len(char_entries.filter(func (entry): return not entry))
	var time_passed := 60 - test_time
	var amount_of_minute_passed := float(time_passed) / 60.0
	var wpm := 0.0 if time_passed == 0 else float(words_typed - errors) / amount_of_minute_passed
	
	var accuracy := 0.0 if total_entries == 0 else float(total_entries - total_errors) / float(total_entries)
	
	return [wpm, accuracy]


######### Client methods #########
@rpc('authority')
func room_successfully_created(_room_id: int):
	pass


@rpc('authority')
func room_filled_and_ready(_room_id: int, _peer_ids: Array):
	pass


@rpc('authority')
func all_players_ready():
	pass


@rpc('authority')
func test_has_started():
	pass


@rpc('authority')
func update_stats(_test_time: int, _players_stats: Dictionary):
	pass


@rpc('authority')
func test_time_ended():
	pass
