extends CharacterBody2D
signal player_hurt

# ---CONSTANTS---

# movement
const ACCELERATION = 30
const MAX_SPEED = 400
const AIR_FRICTION = 0.025

# player
var DEFAULT_DRAIN = 1.0

# ---VARIABLES---

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

	if input_x != 0: # horizontal movement
		velocity.x += input_x * ACCELERATION
	else:
		# taper off speed if there is no input
		velocity.x = lerpf(velocity.x, 0, AIR_FRICTION) if abs(velocity.x) > 5 else 0
	if input_y != 0: # vertical movement
		velocity.y += input_y * ACCELERATION
	else:
		velocity.y = lerpf(velocity.y, 0, AIR_FRICTION) if abs(velocity.y) > 5 else 0
	
	# Clamp movement to maximum speed
	velocity = Vector2(clamp(velocity.x, -MAX_SPEED, MAX_SPEED), clamp(velocity.y, -MAX_SPEED, MAX_SPEED))
	
	# this is VERY temporary
	if Input.is_action_pressed("player_left"):
		direction = -1
		$Sprite.scale.x = -0.688
	if Input.is_action_pressed("player_right"):
		direction = 1
		$Sprite.scale.x = 0.688
	
	move_and_slide()
	
	# Check if health has drained
	if health <= 0 or Input.is_action_just_pressed("restart"):
		die()
	
	debug_label.set_text("Speed: (%f, %f)\nDirection: %d\nHealth: %d\nDrain Rate: %d/sec" % [velocity.x, velocity.y, direction, health, drain_rate])

func hurt(damage_value : int, hurt_type := "enemy"):
	# take a set amount of damage
	health -= damage_value
	if health < 0:
		health = 0
	$HUD.hurt_effect(damage_value)

func die(): # the bee is dead
	get_tree().reload_current_scene()

func _on_drain_timer_timeout():
	# Health drain timer
	hurt(drain_rate, "timer")
