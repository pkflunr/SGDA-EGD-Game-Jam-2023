extends "res://Scenes/Enemy/enemyBase.gd"

@export var orbit_distance = 200
@export var charging_friction : float = 0.003
@export var attack_move_speed : int = 80

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

var attack_speed_decay = 0.3
var rotation_speed = 7
var orbit_dir_clockwise : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = $Icon
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
	if player == null:
		shake_smooth(delta, 100)
		return
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

func charge_sting(delta):
	shake_violent(($StingCharge.wait_time - $StingCharge.time_left) * 8 / $StingCharge.wait_time)
	if ($StingCharge.is_stopped()):
		$StingCharge.start()
	slow_down(delta, charging_friction)
	
	rotate_toward(delta, rotation_speed * max(3 * pow($StingCharge.time_left / $StingCharge.wait_time, 0.5) / 2 - 0.5, 0), get_predicted_player_location($StingCharge.time_left))

func attack(delta):
	if $StingDuration.is_stopped() :
		$StingDuration.start()
	slow_down(delta, attack_speed_decay)

func cooldown(delta):
	if $StingCooldown.is_stopped() :
		$StingCooldown.start()
	
	slow_down(delta, 0.1)
	idle_float(delta, $StingCooldown.time_left)

	orient_self(delta)

func can_sting() -> bool:
	return position.distance_squared_to(player.position) < 9 * pow(orbit_distance, 2)

func generate_orbit_direction() -> void:
	orbit_dir_clockwise = rng.randi_range(0, 1) == 1

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
