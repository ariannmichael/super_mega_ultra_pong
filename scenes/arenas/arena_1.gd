extends Node2D

@onready var hp = $HP

func _on_ball_on_hit_wall(wall_name) -> void:
	if wall_name == "Area2DLeft":
		$HP.decrease(10)

func _ready():
	$Track1.play()
	$Track1.volume_db = 0
	$Track2.play()
	$Track2.volume_db = -80

func _on_arena_timer_short_time_left() -> void:
	$Track1.volume_db = -80
	$Track2.volume_db = 0
