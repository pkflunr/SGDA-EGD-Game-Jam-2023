extends CharacterBody2D

@export var health = 100
@export var player : CharacterBody2D
@export var speed_limit : int = 25
@export var speed_multiplier : float = 30
@export var attack_power : int = 10 # the amount of damage that this enemy does

@export var hp_value : int
@export var is_vulnerable : bool
@export var health_when_possessed = 50

var rot_velocity : int
var sprite : Sprite2D

var unscaledVelocity : Vector2
var curr_state

var rng = RandomNumberGenerator.new()

var shakeDir : Vector2

func shake_smooth(delta, range):
	if(!$ShakeFreq.time_left):
		shakeDir = Vector2( rng.randi_range(-range, range), rng.randi_range(-range, range) )
		$ShakeFreq.start()
	accelerate_in_dir(shakeDir, delta)

func move():
	velocity = unscaledVelocity * speed_multiplier
	move_and_slide()

func shake_violent(max_offset):
	sprite.position = Vector2(rng.randi_range(-max_offset, max_offset), rng.randi_range(-max_offset, max_offset))

func rotate_toward(delta, speed = 1, pos : Vector2 = player.position, isDir : bool = false) :
	# wow I hate how I wrote this, if isDir is true, then pos is taken as a direction vector instead of a position to turn toward
	var angle
	if isDir :
		angle = -pos.angle_to( Vector2.from_angle(sprite.rotation) )
	else :
		angle = -(position - pos).angle_to( Vector2.from_angle(sprite.rotation) ) 
	
	sprite.rotate((angle if abs(angle) < PI else angle + (2 * PI * -sign(angle))) * delta * speed)

func accelerate_in_dir(dir : Vector2, delta, limit : float = speed_limit):
	unscaledVelocity += dir * delta
	unscaledVelocity = unscaledVelocity.limit_length(limit)

func get_predicted_player_location(time : float) -> Vector2:
	return player.position + player.velocity * time

func idle_float(delta, time : float):
	accelerate_in_dir(Vector2.UP * (sin(time * PI)) * 20, delta)

func knockback(kb_vector : Vector2, rot : int):
	unscaledVelocity = kb_vector
	rot_velocity = rot

func slow_down(delta : float, friction : float) -> void:
	unscaledVelocity *= pow(friction, delta)

func slow_rot(delta : float, friction : float) -> void:
	rot_velocity *= pow(friction, delta)

# DOES NOT WORK WITH rotate_toward()
func rotate_with_rot_vel(delta) :
	sprite.rotate(delta * rot_velocity)

func look_at_player_horizontal():
	if player.position.x > position.x :
		sprite.scale.x = -1
	else :
		sprite.scale.x = 1

func orient_self(delta):
	if abs(Vector2.LEFT.angle_to(Vector2.from_angle(sprite.rotation))) < abs(Vector2.RIGHT.angle_to(Vector2.from_angle(sprite.rotation))) :
		rotate_toward(delta, 1, Vector2.LEFT, true)
	else:
		rotate_toward(delta, 1, Vector2.RIGHT, true)

func force_horizontal_orientation():
	if abs(Vector2.LEFT.angle_to(Vector2.from_angle(sprite.rotation))) < abs(Vector2.RIGHT.angle_to(Vector2.from_angle(sprite.rotation))) :
		sprite.rotation = PI
	else:
		sprite.rotation = 0

func damage(damage):
	health -= damage
	$AnimationPlayer.play("damage flash")
