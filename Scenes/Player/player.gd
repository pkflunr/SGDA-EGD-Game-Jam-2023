extends CharacterBody2D

# CONSTANTS

# movement
const ACCELERATION = 30
const MAX_SPEED = 400
const AIR_FRICTION = 0.025

# player
var DEFAULT_DRAIN = 1.0

# VARIABLES

# movement
var direction = 1 # 1 is right, -1 is left

# player
var health = 50
var drain_rate = DEFAULT_DRAIN

@onready var debug_label = $CanvasLayer/Label

func _physics_process(delta):
	# Movement stuff
	var input_x = Input.get_axis("player_left", "player_right")
	var input_y = Input.get_axis("player_up", "player_down")

	if input_x != 0:
		velocity.x += input_x * ACCELERATION
	else:
		velocity.x = lerpf(velocity.x, 0, AIR_FRICTION) if abs(velocity.x) > 5 else 0
	if input_y != 0:
		velocity.y += input_y * ACCELERATION
	else:
		velocity.y = lerpf(velocity.y, 0, AIR_FRICTION) if abs(velocity.y) > 5 else 0
	
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	
	# this is VERY temporary
	if Input.is_action_just_pressed("player_left"):
		direction = -1
		$Sprite.scale.x = -0.688
	if Input.is_action_just_pressed("player_right"):
		direction = 1
		$Sprite.scale.x = 0.688
	
	debug_label.set_text("Speed: (%f, %f)\nDirection: %d\nHealth: %d\nDrain Rate: %d/sec" % [velocity.x, velocity.y, direction, health, drain_rate])
	
	move_and_slide()

	if health <= 0:
		die()

func die():
	get_tree().reload_current_scene()

func _on_timer_timeout():
	if health > 0:
		health -= drain_rate
		if health < 0:
			health = 0
