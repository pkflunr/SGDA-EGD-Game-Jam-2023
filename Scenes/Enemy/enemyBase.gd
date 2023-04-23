extends CharacterBody2D

@export var health = 100
@export var player : CharacterBody2D
@export var speed_limit : int = 25
@export var speed_multiplier : float = 30
@export var attack_power : int = 10 # the amount of damage that this enemy does
@export var vulnerability_threshold = 20
@export var is_vulnerable : bool
@export var health_when_possessed = 50

var rot_velocity : float
var sprite : Sprite2D
var idle_pos : Vector2

var unscaledVelocity : Vector2
var curr_state

var dying_state
var vulnerable_state
var normal_state

var rng = RandomNumberGenerator.new()

var shakeDir : Vector2

func _ready():
	sprite = $Icon
	idle_pos = position

func idle(delta):
	accelerate_in_dir(idle_pos - position, delta * 2)
	shake_smooth(delta, 10)
	slow_down(delta, 0.3)
	move()

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

func aggro():
	curr_state = normal_state

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

func vertical_flip_look_up():
	if (cos(sprite.rotation) < 0) :
		sprite.scale.y = -1
	else:
		sprite.scale.y = 1

func orient_self_gradual(delta):
	if abs(Vector2.LEFT.angle_to(Vector2.from_angle(sprite.rotation))) < abs(Vector2.RIGHT.angle_to(Vector2.from_angle(sprite.rotation))) :
		rotate_toward(delta, 1, Vector2.LEFT, true)
	else:
		rotate_toward(delta, 1, Vector2.RIGHT, true)

func force_horizontal_orientation():
	if abs(Vector2.LEFT.angle_to(Vector2.from_angle(sprite.rotation))) < abs(Vector2.RIGHT.angle_to(Vector2.from_angle(sprite.rotation))) :
		sprite.rotation = PI
	else:
		sprite.rotation = 0

func vulnerable(delta):
	rotate_with_rot_vel(delta)
	slow_rot(delta, 0.2)
	slow_down(delta, 0.2)
	move()

func die():
	$AnimationPlayer.stop()
	sprite.modulate.a = 0
	$enemyHPBar.modulate.a = 0
	self.set_collision_layer_value(3, false)
	$DeathParticle.emitting = true
	$DeathLength.start()

func damage(damage):
	health -= damage
	if !is_vulnerable:
		if health < vulnerability_threshold:
			$AnimationPlayer.play("vulnerability flashing")
			$VulnerableLength.start()
			is_vulnerable = true
			curr_state = vulnerable_state
			var knockback_vector
			if player == null:
				knockback_vector = Vector2.from_angle(randf_range(0, 2 * PI))
			else:
				knockback_vector = (position - player.position).normalized()
			knockback(knockback_vector * 10, 20)
		else:
			$AnimationPlayer.play("damage flash")
	elif health <= 0 and curr_state != dying_state:
		curr_state = dying_state
		die()

func _on_death_length_timeout():
	queue_free()


func _on_vulnerable_length_timeout():
	aggro()
