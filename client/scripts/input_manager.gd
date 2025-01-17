extends Node

@onready var http_request: HTTPRequest = $HTTPRequest

signal key_event(key: String, typed_char: String, is_press: bool)
signal test_copy_loaded(copy: String)
signal char_pos_updated(pos: int)

const default_test_copy = 'Habits are powerful forces in our lives. They shape our daily routines, influence our decisions, and define who we are. Developing good habits can lead to long-term success, while breaking bad ones can be challenging but transformative. The key to building lasting habits lies in consistency and patience. Start small and focus on incremental progress. Celebrate your achievements along the way, no matter how minor they may seem. Over time, these small actions accumulate, leading to significant change. Remember, the path to self-improvement is not a sprint but a marathon. Stay committed and trust the process.'

var typed_char := ''
var typed_combination := ''
var char_pos := 0
var test_copy := ''

func _ready() -> void:
	_load_test_copy()

func _load_test_copy() -> void:
	http_request.request_completed.connect(_on_test_copy_request_completed)
	http_request.request("https://raw.githubusercontent.com/davis-trem/TypingRace/refs/heads/main/client/test_copy/test1.txt")


func _on_test_copy_request_completed(
	result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result == HTTPRequest.RESULT_SUCCESS:
		test_copy = body.get_string_from_utf8()
	else:
		test_copy = default_test_copy
	
	test_copy_loaded.emit(test_copy)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.echo:
		var key: String = OS.get_keycode_string(event.key_label)
		typed_char = char(event.unicode)
		
		if event.pressed:
			key_event.emit(key, typed_char, true)
			typed_combination = event.as_text()
			
			if typed_char == '':
				if char_pos > 0 and (event.keycode == KEY_BACKSPACE or event.keycode == KEY_DELETE):
					char_pos -= 1
					char_pos_updated.emit(char_pos)
				return
			
			char_pos += 1
			char_pos_updated.emit(char_pos)
		else:
			key_event.emit(key, typed_char, false)
