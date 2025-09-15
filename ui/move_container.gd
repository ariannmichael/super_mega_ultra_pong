extends Node

@export var initial_offset: float = 80.0
@export var movement_delta: float = 10.0
@export var container: Container

var tween: Tween = create_tween()

func _ready() -> void:
	var base_pos = container.position
	
	tween.set_loops()
	tween.tween_property(container, "position:y", (base_pos.y - movement_delta) + initial_offset, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(container, "position:y", base_pos.y + initial_offset, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
