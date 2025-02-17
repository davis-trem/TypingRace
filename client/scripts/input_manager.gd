extends Node

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var one_sec_timer: Timer = $OneSecTimer
@onready var onscreen_keyboard: PanelContainer = $'../OnscreenKeyboard'

signal key_event(key: String, typed_char: String, is_press: bool)
signal test_copy_loaded(copy: String)
signal char_pos_updated(pos: int)
signal test_time_updated(time: int, wpm: float, accuracy: float)

const default_test_copy := 'Habits are powerful forces in our lives. They shape our daily routines, influence our decisions, and define who we are. Developing good habits can lead to long-term success, while breaking bad ones can be challenging but transformative. The key to building lasting habits lies in consistency and patience. Start small and focus on incremental progress. Celebrate your achievements along the way, no matter how minor they may seem. Over time, these small actions accumulate, leading to significant change. Remember, the path to self-improvement is not a sprint but a marathon. Stay committed and trust the process.'
const filenames := ['test1.txt', 'test2.txt', 'test3.txt']

var typed_char := ''
var typed_combination := ''
var char_pos := 0
var test_copy := ''
var give_test_time := 60
var test_time := give_test_time
var char_entries := []
var total_entries :int= 0
var total_errors :int= 0

func _ready() -> void:
	_load_test_copy()


func _start_test():
	test_time = give_test_time
	char_entries = []
	total_entries = 0
	total_errors = 0
	test_time_updated.emit(test_time, 0.0, 1.0)
	one_sec_timer.start()


func _load_test_copy() -> void:
	http_request.request_completed.connect(_on_test_copy_request_completed)
	var filename = filenames.pick_random()
	http_request.request(
		'https://raw.githubusercontent.com/davis-trem/TypingRace/refs/heads/main/client/test_copy/{0}'.format(
			[filename]
		)
	)


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
					char_entries.pop_back()
					char_pos -= 1
					char_pos_updated.emit(char_pos)
					
					var wpm_and_accuracy := _calculate_wpm_and_accuracy()
					test_time_updated.emit(test_time, wpm_and_accuracy[0], wpm_and_accuracy[1])
				return
			
			# Begin Test when typing starts
			if one_sec_timer.is_stopped() and test_time != 0:
				_start_test()
			
			total_entries += 1
			var correct_char := typed_char == test_copy[char_pos]
			if not correct_char:
				total_errors += 1
			char_entries.append(correct_char)
			char_pos += 1
			char_pos_updated.emit(char_pos)
			
			var wpm_and_accuracy := _calculate_wpm_and_accuracy()
			test_time_updated.emit(test_time, wpm_and_accuracy[0], wpm_and_accuracy[1])
		else:
			key_event.emit(key, typed_char, false)


func _on_one_sec_timer_timeout() -> void:
	test_time -= 1
	
	var wpm_and_accuracy := _calculate_wpm_and_accuracy()
	test_time_updated.emit(test_time, wpm_and_accuracy[0], wpm_and_accuracy[1])
	if test_time == 0:
		one_sec_timer.stop()


func _calculate_wpm_and_accuracy() -> Array[float]:
	var words_typed := len(char_entries) / 5
	var errors := len(char_entries.filter(func (entry): return not entry))
	var time_passed := give_test_time - test_time
	var amount_of_minute_passed := float(time_passed) / 60.0
	var wpm := 0.0 if time_passed == 0 else float(words_typed - errors) / amount_of_minute_passed
	
	var accuracy := 0.0 if total_entries == 0 else float(total_entries - total_errors) / float(total_entries)
	
	return [wpm, accuracy]


func _on_v_keyboard_button_pressed() -> void:
	onscreen_keyboard.visible = not onscreen_keyboard.visible
