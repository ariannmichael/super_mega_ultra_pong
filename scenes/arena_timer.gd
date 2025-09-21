extends Node2D

@onready var timer = $Timer
@onready var label = $RichTextLabel
@export var short_time_seconds = 10

var _emitted = false
signal short_time_left

func get_time_left():
	return timer.time_left

func _ready():
	self.connect("short_time_left", Callable(self, "_short_time_left"))

func _process(delta: float) -> void:
	var seconds_left = int(timer.time_left)
	label.text = str(seconds_left)
	if seconds_left == short_time_seconds and not _emitted:
		emit_signal("short_time_left")
		_emitted = true

func _on_timer_timeout() -> void:
	pass # Replace with function body.
	
