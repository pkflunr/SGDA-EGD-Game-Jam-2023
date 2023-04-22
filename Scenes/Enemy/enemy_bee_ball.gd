extends Area2D

@export var aggro_target:Node2D
@export var acceleration = 640 # in pixels/sec/sec
@export var terminal_velocity = 400

@onready var gpu_particles_2d = $GPUParticles2D


var velocity:Vector2 = Vector2.ZERO

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if aggro_target != null:
		velocity += position.direction_to(aggro_target.position) * acceleration * delta
		velocity = velocity.limit_length(terminal_velocity)
		position += velocity * delta
	
	
