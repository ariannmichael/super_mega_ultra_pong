extends CanvasLayer

@onready var buttons_container: VBoxContainer = $Control/MarginContainer/VBoxContainer/ButtonsContainer

@export var initial_offset: float = 80.0
@export var movement_delta: float = 10.0

var tween: Tween = create_tween()

func _ready() -> void:
	var base_pos = buttons_container.position
	
	tween.set_loops()
	tween.tween_property(buttons_container, "position:y", (base_pos.y - movement_delta) + initial_offset, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(buttons_container, "position:y", base_pos.y + initial_offset, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	

func _on_button_pressed() -> void:
	$"/root/LevelManager".increment_level()
