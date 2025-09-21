extends RigidBody2D

signal on_hit_wall

@onready var particles = $GPUParticles2D
@onready var collision = $CollisionShape2D

@export var ball_scale = 0.3
@export var initial_velocity = 50
var inflation_scale = 0.1
var max_allowed_scale = 1.2
var min_allowed_scale = 0.3


func _ready():
	linear_velocity = Vector2(initial_velocity, -150)
	self.connect("on_hit_wall", Callable(self, "_on_hit_wall"))

func _physics_process(delta: float) -> void:
	particles.process_material.scale_min = ball_scale
	particles.process_material.scale_max = ball_scale
	collision.scale = Vector2(ball_scale, ball_scale)
	
func slow_down():
	pass

func accelerate():
	pass

func inflate():
	if (inflation_scale + ball_scale) >= max_allowed_scale:
		ball_scale = max_allowed_scale
	else:
		ball_scale += inflation_scale

func deflate():
	if (ball_scale - inflation_scale) <= min_allowed_scale:
		ball_scale = min_allowed_scale
	else:
		ball_scale -= (inflation_scale * 3)

func _on_body_entered(body: Node) -> void:
	if body is StaticBody2D:
		$AudioWall.play()
		emit_signal("on_hit_wall", body.name)
		inflate()
