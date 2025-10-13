extends Control

@onready var description: Label = $Panel/CenterContainer/ColorRect/MarginContainer/VBoxContainer/Description
@onready var no_button: Button = $Panel/CenterContainer/ColorRect/MarginContainer/VBoxContainer/OptionsContainer/NoButton
@onready var yes_button: Button = $Panel/CenterContainer/ColorRect/MarginContainer/VBoxContainer/OptionsContainer/YesButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	no_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
