extends Node

@onready var http_request: HTTPRequest = $'../HTTPRequest'

signal key_event(key: String, typed_char: String, is_press: bool)

const shifted_char := {
	
}

var typed_char := ''
var typed_combination := ''

func _ready() -> void:
	pass


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.echo:
		var key: String = OS.get_keycode_string(event.key_label)
		typed_char = char(event.unicode)
		if event.pressed:
			key_event.emit(key, typed_char, true)
			typed_combination = event.as_text()
		else:
			key_event.emit(key, typed_char, false)
