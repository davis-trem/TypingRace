class_name TypingScreen
extends Control

@onready var cursor: ColorRect = $InformationContainer/VBoxContainer/RichTextLabel/Cursor
@onready var rich_text_label: RichTextLabel = $InformationContainer/VBoxContainer/RichTextLabel
@onready var information_container: MarginContainer = $InformationContainer
@onready var loading_spinner: ColorRect = $LoadingSpinner
@onready var test_time_label: Label = $InformationContainer/VBoxContainer/MarginContainer/HBoxContainer/TestTime
@onready var player_stats: HBoxContainer = $InformationContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/PlayerStats
@onready var player_label: Label = $InformationContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/PlayerStats/You
@onready var words_per_min_label: Label = $InformationContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/PlayerStats/WordsPerMin
@onready var accuracy_label: Label = $InformationContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/PlayerStats/Accuracy
@onready var opponent_stats: HBoxContainer = $InformationContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/OpponentStats
@onready var opponent_words_per_min_label: Label = $InformationContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/OpponentStats/WordsPerMin
@onready var opponent_accuracy_label: Label = $InformationContainer/VBoxContainer/MarginContainer/HBoxContainer/VBoxContainer/OpponentStats/Accuracy


const CHAR_WIDTH = 22.5

var rich_text_regex = RegEx.new()
var char_pos = 0

func _ready() -> void:
	information_container.hide()
	rich_text_regex.compile(r"\[color=.*?\].\[/color\]|.")
	
	player_label.visible = Server.in_multiplayer_test
	opponent_stats.visible = Server.in_multiplayer_test


func handle_key_event(typed_char: String, is_pressed: bool) -> void:
	(cursor.material as ShaderMaterial).set_shader_parameter('should_blink', not is_pressed)
	
	if typed_char == '' or len(rich_text_label.text) == 0 or char_pos == len(rich_text_label.text) - 1:
		return
		
	if is_pressed:
		var chars := _get_rich_text_chars()
		if chars[char_pos] != typed_char:
			rich_text_label.text = (
				''.join(chars.slice(0, char_pos))
				+ '{0}{1}{2}'.format(['[color=red]', chars[char_pos], '[/color]'])
				+ ''.join(chars.slice(char_pos + 1))
			)


func _get_rich_text_chars() -> Array:
	var matches = rich_text_regex.search_all(rich_text_label.text)
	return matches.map(func (m): return m.get_string())


func on_char_pos_updated(pos: int) -> void:
	var chars := _get_rich_text_chars()
	rich_text_label.text = (
		''.join(chars.slice(0, pos))
		+ chars[pos].replace('[color=red]', '').replace('[/color]', '')
		+ ''.join(chars.slice(pos + 1))
	)
	
	var line = rich_text_label.get_character_line(pos)
	rich_text_label.scroll_to_line(line)
	var char_line_index = _get_relative_line_pos(pos)
	cursor.position.x = CHAR_WIDTH * char_line_index
	
	char_pos = pos


func _get_relative_line_pos(pos: int) -> int:
	var line = rich_text_label.get_character_line(pos)
	if line == 0:
		return pos
	
	var pos_of_first_char_in_line = pos
	while rich_text_label.get_character_line(pos_of_first_char_in_line - 1) == line:
		pos_of_first_char_in_line -= 1
	
	return pos - pos_of_first_char_in_line


func set_test_copy(copy: String) -> void:
	rich_text_label.text = copy
	rich_text_label.scroll_to_line(0)
	char_pos = 0
	
	loading_spinner.hide()
	information_container.show()


func update_test_time(time: int, wpm: float, accuracy: float) -> void:
	var minute := time / 60
	var sec := '{0}'.format([time % 60]).pad_zeros(2)
	test_time_label.text = '{0}:{1}'.format([minute, sec])
	
	words_per_min_label.text = '{0} Words Per Minute'.format([roundi(wpm)])
	
	accuracy_label.text = 'Accuracy {0}%'.format([roundi(accuracy * 100)])


func update_opponent_stats(wpm: float, accuracy: float) -> void:
	opponent_words_per_min_label.text = '{0} Words Per Minute'.format([roundi(wpm)])
	
	opponent_accuracy_label.text = 'Accuracy {0}%'.format([roundi(accuracy * 100)])


func reset_test() -> void:
	test_time_label.text = '0:00'
	words_per_min_label.text = 'Start Typing To Begin'
	accuracy_label.text = 'Accuracy 100%'
	char_pos = 0
	cursor.position.x = 0
	rich_text_label.scroll_to_line(0)
	
