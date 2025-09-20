extends RigidBody2D
@onready var particles = $GPUParticles2D
@onready var collision = $CollisionShape2D

@export var ball_scale = 0.3

func _ready():
	linear_velocity = Vector2(200, -150)

func _physics_process(delta: float) -> void:
	particles.process_material.scale_min = ball_scale
	particles.process_material.scale_max = ball_scale
	collision.scale = Vector2(ball_scale, ball_scale)
