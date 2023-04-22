extends CharacterBody2D

@export var health = 100
@export var orbit_distance = 150
@export var player : CharacterBody2D
@export var speed_limit : int = 25
@export var speed_multiplier : float = 30
@export var charging_friction : float = 0.003
@export var attack_move_speed : int = 70
@export var attack_power : int = 10 # the amount of damage that this enemy does

enum StingerEnemyStates {
	ORBIT,
	CHARGE_STING,
	ATTACK,
	COOLDOWN,
	HIT,
	DYING,
	VULNERABLE,
	DEATH
}

var unscaledVelocity : Vector2
var curr_state : StingerEnemyStates

var attack_speed_decay = 0.3
var rotation_speed = 7
var orbit_dir_clockwise : bool
var rng = RandomNumberGenerator.new()

var shakeDir : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	if player == null:
		print("bruh the stinger enemy doesn't have a player skull emoji")
		player = self
	curr_state = StingerEnemyStates.ORBIT
	generate_orbit_direction()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = unscaledVelocity * speed_multiplier
	move_and_slide()
	
	if (cos($Icon.rotation) < 0) :
		$Icon.scale.y = -1
	else:
		$Icon.scale.y = 1

	match curr_state:
		StingerEnemyStates.ORBIT:
			orbit_player(delta)
		StingerEnemyStates.CHARGE_STING:
			charge_sting(delta)
		StingerEnemyStates.ATTACK:
			attack(delta)
		StingerEnemyStates.COOLDOWN:
			cooldown(delta)
		StingerEnemyStates.HIT:
			pass
		StingerEnemyStates.VULNERABLE:
			pass
		StingerEnemyStates.DYING:
			pass
		StingerEnemyStates.DEATH:
			self.queue_free()

# the orbitting is kinda fricked but I'm not going to bother rn
func orbit_player(delta):
	shake_smooth(delta, 100)
	var target_pos
	if (orbit_dir_clockwise):
		target_pos = player.position + Vector2.from_angle((position - player.position).angle() + PI / 6) * orbit_distance
	else:
		target_pos = player.position + Vector2.from_angle((position - player.position).angle() - PI / 6) * orbit_distance
	accelerate_in_dir(target_pos - position, delta / orbit_distance * 100)
	if ($StingTargettedWait.is_stopped() and can_sting()):
		$StingTargettedWait.start()
	rotate_toward(delta, rotation_speed)

func shake_smooth(delta, range):
	if(!$ShakeFreq.time_left):
		shakeDir = Vector2( rng.randi_range(-range, range), rng.randi_range(-range, range) )
		$ShakeFreq.start()
	accelerate_in_dir(shakeDir, delta)

func shake_violent(max_offset):
	$Icon.position = Vector2(rng.randi_range(-max_offset, max_offset), rng.randi_range(-max_offset, max_offset))

func charge_sting(delta):
	shake_violent(($StingCharge.wait_time - $StingCharge.time_left) * 8 / $StingCharge.wait_time)
	if ($StingCharge.is_stopped()):
		$StingCharge.start()
	slow_down(charging_friction, delta)
	
	rotate_toward(delta, rotation_speed * max($StingCharge.time_left / $StingCharge.wait_time - 0.25, 0), get_predicted_player_location($StingCharge.time_left))

func attack(delta):
	if $StingDuration.is_stopped() :
		$StingDuration.start()
	slow_down(attack_speed_decay, delta)

func cooldown(delta):
	if $StingCooldown.is_stopped() :
		$StingCooldown.start()
	
	slow_down(0.1, delta)
	accelerate_in_dir(Vector2.UP * (sin($StingCooldown.time_left * PI)) * 20, delta)

	if abs(Vector2.LEFT.angle_to(Vector2.from_angle($Icon.rotation))) < abs(Vector2.RIGHT.angle_to(Vector2.from_angle($Icon.rotation))) :
		rotate_toward(delta, 1, Vector2.LEFT, true)
	else:
		rotate_toward(delta, 1, Vector2.RIGHT, true)

func rotate_toward(delta, speed = 1, pos : Vector2 = player.position, isDir : bool = false) :
	# wow I hate how I wrote this, if isDir is true, then pos is taken as a direction vector instead of a position to turn toward
	var angle
	if isDir :
		angle = -pos.angle_to( Vector2.from_angle($Icon.rotation) )
	else :
		angle = -(position - pos).angle_to( Vector2.from_angle($Icon.rotation) ) 
	
	$Icon.rotate((angle if abs(angle) < PI else angle + (2 * PI * -sign(angle))) * delta * speed)

func can_sting() -> bool:
	return position.distance_squared_to(player.position) < 9 * pow(orbit_distance, 2)

func generate_orbit_direction() -> void:
	orbit_dir_clockwise = rng.randi_range(0, 1) == 1

func accelerate_in_dir(dir : Vector2, delta, limit : float = speed_limit):
	unscaledVelocity += dir * delta
	unscaledVelocity = unscaledVelocity.limit_length(limit)

func get_predicted_player_location(time : float) -> Vector2:
	return player.position + player.velocity * time

func slow_down(friction : float, delta : float) -> void:
	unscaledVelocity *= pow(friction, delta)

func _on_stinger_enemy_area_body_entered(body):
	if body == player :
		match curr_state:
			StingerEnemyStates.ATTACK:
				# TODO Damage the player
				curr_state = StingerEnemyStates.COOLDOWN
#			_:
#				# TODO Damage the player but less
#				curr_state = StingerEnemyStates.HIT
#				pass
# TODO detect getting damaged by player

func _on_sting_cooldown_timeout():
	if curr_state == StingerEnemyStates.COOLDOWN:
		curr_state = StingerEnemyStates.ORBIT
		generate_orbit_direction()
	$StingCooldown.stop()

func _on_sting_charge_timeout():
	if curr_state == StingerEnemyStates.CHARGE_STING :
		$Icon.position = Vector2.ZERO
		curr_state = StingerEnemyStates.ATTACK
		unscaledVelocity = -Vector2.from_angle($Icon.rotation) * attack_move_speed
	$StingCharge.stop()

func _on_sting_duration_timeout():
	if curr_state == StingerEnemyStates.ATTACK :
		curr_state = StingerEnemyStates.COOLDOWN
	$StingDuration.stop()

func _on_sting_targetted_wait_timeout():
	if (can_sting() and curr_state == StingerEnemyStates.ORBIT):
		curr_state = StingerEnemyStates.CHARGE_STING
	$StingTargettedWait.stop()
