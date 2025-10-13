extends Node

enum  TEST_TYPE {
	SOLO1,
	SOLO2,
	SOLO3,
	MULTI
}

enum MULTIPLAYER_TYPE {
	JOIN_RANDOM,
	PRIVATE_ROOM,
}

const SCREEN_MAIN_MENU = 'res://scenes/main_menu_screen.tscn'
const SCREEN_TYPING_TEST = 'res://scenes/typing_screen.tscn'
const SCREEN_OPTIONS = 'res://scenes/options_screen.tscn'
const SCREEN_MULTIPLAYER = 'res://scenes/multiplayer_screen.tscn'

signal initializing_test(test_type: TEST_TYPE);
signal retry_test;
signal loading_new_screen(path: String, on_load_complete: Callable, on_screen_initialized: Callable);
signal screen_loaded(screen: Node);
signal loading_complete(on_load_complete: Callable);

var enable_sound_fx := true


func initialize_test(test_type: TEST_TYPE):
	loading_new_screen.emit(
		SCREEN_TYPING_TEST,
		func(): initializing_test.emit(test_type),
		func(_node): return
	)


func change_screen(path: String, on_screen_initialized: Callable = func(_node): return) -> void:
	loading_new_screen.emit(path, func(): loading_complete.emit(), on_screen_initialized)
