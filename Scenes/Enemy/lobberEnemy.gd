extends CharacterBody2D

@export var health = 100
@export var hover_distance = 600
@export var player : CharacterBody2D
@export var speed_limit : int = 50
@export var speed_multiplier : float = 30
@export var attack_power : int = 10

enum ShooterEnemyStates {
	HOVER,
	ATTACK,
	DYING,
	VULNERABLE,
	DEATH
}

var unscaledVelocity : Vector2
var curr_state : ShooterEnemyStates
var rng = RandomNumberGenerator.new()

var hover_y_band_tolerance = 400 
var picked_point : Vector2
var x_point_range = 30
var y_point_range = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	unscaledVelocity = Vector2.ZERO
	if player == null:
		print("bruh the burst shooter enemy doesn't have a player skull emoji")
		player = self
	enter_hover_mode()
	$PickPoint.start()
	generate_hover_point()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if player.position.x > position.x :
		$Icon.scale.x = -1
	else :
		$Icon.scale.x = 1
	velocity = speed_multiplier * unscaledVelocity
	move_and_slide()
	
#	if (cos($Icon.rotation) < 0) :
#		$Icon.scale.x = -1
#	else:
#		$Icon.scale.y = 1

	match curr_state:
		ShooterEnemyStates.HOVER:
			hover(delta)
		ShooterEnemyStates.ATTACK:
			attack(delta)
		ShooterEnemyStates.DYING:
			pass
		ShooterEnemyStates.VULNERABLE:
			pass
		ShooterEnemyStates.DEATH:
			self.queue_free()

func hover(delta):
	accelerate_in_dir((picked_point - position) * 2, delta, 25)
	slow_down(0.2, delta)
	unscaledVelocity.x *= pow(0.5, delta)
	if !$HoverTime.time_left :
		enter_attack()

func generate_hover_point():
	var topLim = -y_point_range if position.y > player.position.y - hover_y_band_tolerance else 0
	var botLim = y_point_range if position.y < player.position.y - hover_y_band_tolerance / 2 else 0
	var offset = rng.randi_range(topLim, botLim)
	picked_point = Vector2(player.position.x + (hover_distance if position.x > player.position.x else -hover_distance) + rng.randi_range(-x_point_range, x_point_range), position.y + offset)

func attack(delta):
	$enemyShooter.fire(player.position - position)
	enter_hover_mode()

func rotate_toward(delta, speed = 1, pos : Vector2 = player.position, isDir : bool = false) :
	# wow I hate how I wrote this, if isDir is true, then pos is taken as a direction vector instead of a position to turn toward
	var angle
	if isDir :
		angle = -pos.angle_to( Vector2.from_angle($Icon.rotation) )
	else :
		angle = -(position - pos).angle_to( Vector2.from_angle($Icon.rotation) ) 
	
	$Icon.rotate((angle if abs(angle) < PI else angle + (2 * PI * -sign(angle))) * delta * speed)

func accelerate_in_dir(dir : Vector2, delta, limit : float = speed_limit):
	unscaledVelocity += (dir * delta)
	unscaledVelocity = unscaledVelocity.limit_length(limit)

func slow_down(friction : float, delta : float) -> void:
	unscaledVelocity *= pow(friction, delta)

func shake_violent(max_offset):
	$Icon.position = Vector2(rng.randi_range(-max_offset, max_offset), rng.randi_range(-max_offset, max_offset))

func get_predicted_player_location(time : float) -> Vector2:
	return player.position + player.velocity * time

func enter_hover_mode() :
	$HoverTime.start()
	curr_state = ShooterEnemyStates.HOVER

func enter_attack() :
	curr_state = ShooterEnemyStates.ATTACK

func _on_pick_point_timeout():
	$Icon.position = Vector2.ZERO
	generate_hover_point()
	$PickPoint.start()

func _on_shooter_enemy_area_body_entered(body):
	if body == player :
		#idk what to do in the situation
		# TODO Damage the player
		# TODO detect getting damaged by player
		pass
