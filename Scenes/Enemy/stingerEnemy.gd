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
	VULNERABLE
}

var attack_speed_decay = 0.3
var rotation_speed = 7
var orbit_dir_clockwise : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	dying_state = StingerEnemyStates.DYING
	vulnerable_state = StingerEnemyStates.VULNERABLE
	normal_state = StingerEnemyStates.ORBIT
	
	curr_state = normal_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null:
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
				hit(delta)
			StingerEnemyStates.VULNERABLE:
				vulnerable(delta)

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
	move()
	vertical_flip_look_up()

func charge_sting(delta):
	shake_violent(($StingCharge.wait_time - $StingCharge.time_left) * 8 / $StingCharge.wait_time)
	if ($StingCharge.is_stopped()):
		$StingCharge.start()
	slow_down(delta, charging_friction)
	
	rotate_toward(delta, rotation_speed * max(3 * pow($StingCharge.time_left / $StingCharge.wait_time, 0.5) / 2 - 0.5, 0), get_predicted_player_location($StingCharge.time_left))
	move()
	vertical_flip_look_up()

func attack(delta):
	if $StingDuration.is_stopped() :
		$StingDuration.start()
	slow_down(delta, attack_speed_decay)
	move()
	vertical_flip_look_up()

func hit(delta):
	$enemyHPBar.modulate.a = 0
	slow_down(delta, charging_friction)
	idle_float(delta, $DeathAfterSting.time_left, 20 * $DeathAfterSting.time_left / $DeathAfterSting.wait_time )
	move()

func cooldown(delta):
	if $StingCooldown.is_stopped() :
		$StingCooldown.start()
	
	slow_down(delta, 0.1)
	idle_float(delta, $StingCooldown.time_left)

	orient_self_gradual(delta)
	move()

func can_sting() -> bool:
	return position.distance_squared_to(player.position) < 9 * pow(orbit_distance, 2)

func generate_orbit_direction() -> void:
	orbit_dir_clockwise = rng.randi_range(0, 1) == 1

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
		$frames.play("flip back")
		curr_state = StingerEnemyStates.COOLDOWN
	$StingDuration.stop()

func _on_sting_targetted_wait_timeout():
	if (can_sting() and curr_state == StingerEnemyStates.ORBIT):
		$frames.play("flip over")
		curr_state = StingerEnemyStates.CHARGE_STING
	$StingTargettedWait.stop()


func _on_death_after_sting_timeout():
	$DeathDmgAnimationDelay.stop()
	curr_state = dying_state
	die()


func _on_death_dmg_animation_delay_timeout():
	$AnimationPlayer.play("damage flash")


func _on_enemy_area_body_entered(body):
	print("hi")
	if body == player :
		match curr_state:
			StingerEnemyStates.ATTACK:
				# TODO Damage the player
				player.hurt(20)
				$DeathAfterSting.start()
				$DeathDmgAnimationDelay.start()
				curr_state = StingerEnemyStates.HIT
				$frames.play("flip back")
			_:
				player.hurt(5)


func _on_frames_animation_finished(anim_name):
	if anim_name == "flip over":
		$frames.play("charge_sting_idle")
	if anim_name == "flip back":
		$frames.play("idle")
