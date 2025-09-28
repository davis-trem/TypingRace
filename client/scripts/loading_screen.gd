extends Control

@onready var progress_bar: ProgressBar = $Background/InformationContainer/VBoxContainer/ProgressBar
@onready var label: Label = $Background/InformationContainer/VBoxContainer/CenterContainer/Label

var new_screen_path: String
var on_load_complete: Callable
var on_screen_initialized: Callable

var elapsed_time := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.loading_complete.connect(queue_free)
	ResourceLoader.load_threaded_request(new_screen_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta * 4 # every 1/4 of a sec
	label.text = 'Loading{0}'.format(['.'.repeat(int(elapsed_time) % 4)])
	
	var progress := []
	ResourceLoader.load_threaded_get_status(new_screen_path, progress)
	progress_bar.value = progress[0] * 100
	
	if progress[0] == 1:
		var new_screen_scene : PackedScene = ResourceLoader.load_threaded_get(new_screen_path)
		var screen := new_screen_scene.instantiate()
		on_screen_initialized.call(screen)
		screen.hide()
		add_sibling(screen)
		SceneManager.screen_loaded.emit(screen)
		on_load_complete.call()
