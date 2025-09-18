extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var attack_area = $Area2D
var speed = 200
var dash_speed = 800
var attacking = false
var dashing = false
var jumping = false
var dash_cooldown = 0.2
var direction: Vector2


func _physics_process(delta: float) -> void:
	moveset_animation(delta)
	InputManager.execute_if_pressed(self)

func get_animation():
	if dashing:
		return "Attack01"
	if attacking:
		return "Attack02"
	if velocity.x == 0:
		return "Idle"
	else:
		return "Walk"
	
func moveset_animation(_delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if dashing:
		attack_area.scale.x = direction.x
		velocity = direction.normalized() * dash_speed
	else:
		velocity = direction * speed
		
	move_and_slide()
	
	# Animation logic
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true
	anim.play(get_animation())

func jump() -> void:
	print("JUMP JUMP JUMP")

func dash() -> void:
	if direction != Vector2.ZERO:
		dashing = true
		$Timer.start(dash_cooldown)

func attack() -> void:
	attack_area.scale.x = direction.x
	attacking = true
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack02":
		attacking = false
		anim.speed_scale = 1

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	anim.speed_scale = 1
	if anim_name == "Attack01":
		anim.speed_scale = 3
	if anim_name == "Attack02":
		anim.speed_scale = 2

func _on_timer_timeout() -> void:
	dashing = false
