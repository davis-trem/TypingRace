extends Node

@onready var http_request: HTTPRequest = $HTTPRequest

signal key_event(key: String, typed_char: String, is_press: bool)
signal test_copy_loaded(copy: String)
signal char_pos_updated(pos: int)

const shifted_char := {
	
}

var typed_char := ''
var typed_combination := ''
var char_pos := 0
var test_copy := ''

func _ready() -> void:
	http_request.request_completed.connect(_on_test_copy_request_completed)
	http_request.request("https://raw.githubusercontent.com/davis-trem/TypingRace/refs/heads/main/client/test_copy/test1.txt")


func _on_test_copy_request_completed(
	result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray
) -> void:
	test_copy = body.get_string_from_utf8()
	test_copy_loaded.emit(test_copy)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.echo:
		var key: String = OS.get_keycode_string(event.key_label)
		typed_char = char(event.unicode)
		
		if event.pressed:
			key_event.emit(key, typed_char, true)
			typed_combination = event.as_text()
			
			if test_copy[char_pos] != typed_char:
				return
			
			char_pos += 1
			char_pos_updated.emit(char_pos)
		else:
			key_event.emit(key, typed_char, false)
