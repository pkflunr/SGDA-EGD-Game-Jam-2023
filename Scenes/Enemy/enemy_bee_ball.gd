extends CharacterBody2D

@export var aggro_target:Node2D
@export var acceleration = 640 # in pixels/sec/sec
@export var terminal_velocity = 400
@export var health = 20

@onready var gpu_particles_2d = $GPUParticles2D
@onready var gpu_particles_2d2 = $GPUParticles2D2
@onready var contact_damage_area = $ContactDamageArea


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if aggro_target != null:
		velocity += position.direction_to(aggro_target.position) * acceleration * delta
		velocity = velocity.limit_length(terminal_velocity)
		move_and_slide()

func _process(delta):
	if(health <= 0):
		# this might be too extra LMAO feel free to just make it queue free instaed
		aggro_target = null
		$DieTimer.start
		$CollisionShape2D.disabled = true
		gpu_particles_2d.lifetime = 0.5
		gpu_particles_2d2.lifetime = 0.5
		gpu_particles_2d.emitting = false
		gpu_particles_2d2.emitting = false


func _on_contact_damage_timer_timeout():
	for body in contact_damage_area.get_overlapping_bodies():
		if body.has_method("hurt") and not body.is_in_group("enemy"):
			body.hurt(1)


func _on_die_timer_timeout():
	self.queue_free()
