extends Node

var multiplayer_peer := ENetMultiplayerPeer.new()
const host := '127.0.0.1'
const port := 1909
var room_id: int
var players: Dictionary[int, int] = {} # { [peer_id: int]: instance_id: int }
var in_multiplayer_test := false

signal joined_room_and_waiting(room_id: int)
signal room_ready_to_start(room_id: int, peer_ids: Array)
signal multiplayer_test_has_started
signal test_stats_updated(test_time: int, players_stats: Dictionary)

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


func confirm_ready_for_test():
	ready_for_test.rpc_id(1, room_id)


@rpc('authority')
func room_successfully_created(_room_id: int):
	room_id = _room_id
	joined_room_and_waiting.emit(_room_id)


@rpc('authority')
func room_filled_and_ready(_room_id: int, peer_ids: Array):
	room_id = _room_id
	room_ready_to_start.emit(_room_id, peer_ids)


@rpc('authority')
func all_players_ready():
	in_multiplayer_test = true
	SceneManager.initialize_test(SceneManager.TEST_TYPE.MULTI)


@rpc('authority')
func test_has_started():
	multiplayer_test_has_started.emit()


@rpc('authority')
func update_stats(test_time: int, players_stats: Dictionary):
	test_stats_updated.emit(test_time, players_stats)


@rpc('authority')
func test_time_ended():
	pass


######### Server methods #########
@rpc('any_peer')
func join_random_room():
	pass


@rpc('any_peer')
func ready_for_test(_room_id: int):
	pass


@rpc('any_peer')
func start_test(_room_id: int):
	pass


@rpc('any_peer')
func on_test_key_input(
	room_id: int,
	char_entries: Array,
	total_entries: int,
	total_errors: int,
):
	pass
