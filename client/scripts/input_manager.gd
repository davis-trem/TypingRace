extends Node

signal key_event(key: String, is_press: bool)

const shifted_char := {
	
}

var typed_char := ''
var typed_combination := ''

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.echo:
		var key: String = OS.get_keycode_string(event.key_label)
		if event.pressed:
			key_event.emit(key, true)
			typed_char = char(event.unicode)
			typed_combination = event.as_text()
			prints(event.as_text(),'typed_char:', typed_char)
		else:
			key_event.emit(key, false)
