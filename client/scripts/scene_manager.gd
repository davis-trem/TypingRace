extends Node

enum  TEST_TYPE {
	SOLO1,
	SOLO2,
	SOLO3,
}

const SCREEN_MAIN_MENU = 'res://scenes/main_menu_screen.tscn'
const SCREEN_TYPING_TEST = 'res://scenes/typing_screen.tscn'

signal initializing_test(test_type: TEST_TYPE);
signal retry_test;
signal loading_new_screen(path: String, on_load_complete: Callable);
signal screen_loaded(screen: Node);
signal loading_complete;


func initialize_test(test_type: TEST_TYPE):
	loading_new_screen.emit(SCREEN_TYPING_TEST, func(): initializing_test.emit(test_type))


func change_screen(path: String) -> void:
	loading_new_screen.emit(path, func(): loading_complete.emit())
