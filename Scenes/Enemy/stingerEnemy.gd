extends Area2D

@export var health = 100
@export var orbit_distance = 100
@export var player : Node2D
@export var speed_limit : int = 20
@export var speed_multiplier : float = 0.5
@export var charging_friction : float = 0.05
@export var attack_move_speed : int = 10
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

var currState : StingerEnemyStates

var orbitDirClockwise : bool
var velocity : Vector2
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2.ZERO
	if player == null:
		player = self
	currState = StingerEnemyStates.ORBIT
	generate_orbit_direction()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if (cos(rotation) < 0) :
#		$Icon.set_flip_h(true)
#	else:
#		$Icon.set_flip_h(false)
# idk why but this isn't working rn, isn't flipping the image

	match currState:
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
			set_process(false)

# the orbitting is kinda fricked but I'm not going to bother rn
func orbit_player(delta):
	var target_pos
	if (orbitDirClockwise):
		target_pos = player.position + Vector2.from_angle((position - player.position).angle() + PI / 3) * orbit_distance
	else:
		target_pos = player.position + Vector2.from_angle((position - player.position).angle() - PI / 3) * orbit_distance
	accelerate_in_dir(target_pos - position, delta)
	move(delta)
	if ($StingTargettedWait.is_stopped() and can_sting()):
		$StingTargettedWait.start()
	rotate_toward(delta, 10)

func charge_sting(delta):
	if ($StingCharge.is_stopped()):
		$StingCharge.start()
	slow_down(charging_friction, delta)
	
	rotate_toward(delta, 10 * pow($StingCharge.time_left / $StingCharge.wait_time, 3) )
	move(delta)

func attack(delta):
	if $StingDuration.is_stopped() :
		$StingDuration.start()
	
	accelerate_in_dir(-Vector2.from_angle(rotation) * 300, delta, false)
	move(delta)

func cooldown(delta):
	if $StingCooldown.is_stopped() :
		$StingCooldown.start()
	
	slow_down(0.1, delta)
	accelerate_in_dir(Vector2.UP * (sin($StingCooldown.time_left * PI)) * 20, delta)
	move(delta)
	
	if abs(Vector2.LEFT.angle_to(Vector2.from_angle(rotation))) < abs(Vector2.RIGHT.angle_to(Vector2.from_angle(rotation))) :
		rotate_toward(delta, 1, Vector2.LEFT)
	else:
		rotate_toward(delta, 1, Vector2.RIGHT)

func rotate_toward(delta, speed = 1, pos : Vector2 = player.position) :
	var angle = -(position - pos).angle_to( Vector2.from_angle(rotation) )
	
	rotate((angle if abs(angle) < PI else angle + (2 * PI * -sign(angle))) * delta * speed)

func can_sting() -> bool:
	return position.distance_squared_to(player.position) < pow(orbit_distance + 50, 2)

func _on_sting_cooldown_timeout():
	if currState == StingerEnemyStates.COOLDOWN:
		currState = StingerEnemyStates.ORBIT
		generate_orbit_direction()

func generate_orbit_direction() -> void:
	orbitDirClockwise = rng.randi_range(0, 1) == 1

func accelerate_in_dir(dir : Vector2, delta, limited : bool = true):
	velocity += (dir * delta / orbit_distance * 100)
	if limited:
		velocity = velocity.limit_length(speed_limit)

func move(delta):
	position += velocity * speed_multiplier

func slow_down(friction : float, delta : float) -> void:
	velocity *= pow(friction, delta)

func _on_sting_charge_timeout():
	currState = StingerEnemyStates.ATTACK
	$StingCharge.stop()
	velocity = Vector2.ZERO

func _on_sting_duration_timeout():
	if currState == StingerEnemyStates.ATTACK :
		currState = StingerEnemyStates.COOLDOWN
	$StingDuration.stop()

func _on_body_entered(body):
	if body == player :
		match currState:
			StingerEnemyStates.ATTACK:
				# TODO Damage the player
				currState = StingerEnemyStates.COOLDOWN
				pass
#			_:
#				# TODO Damage the player but less
#				currState = StingerEnemyStates.HIT
#				pass
# TODO detect getting damaged by player

func _on_sting_targetted_wait_timeout():
	if (can_sting()):
		currState = StingerEnemyStates.CHARGE_STING
	$StingTargettedWait.stop()
