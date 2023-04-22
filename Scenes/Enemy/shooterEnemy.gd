extends Area2D

@export var health = 100
@export var hover_distance = 300
@export var player : Node2D
@export var speed_limit : int = 50
@export var speed_multiplier : float = 0.5
@export var attack_power : int = 10

enum ShooterEnemyStates {
	HOVER,
	ATTACK,
	DYING,
	VULNERABLE,
	DEATH
}

var velocity : Vector2
var curr_state : ShooterEnemyStates
var rng = RandomNumberGenerator.new()

var hover_band_tolerance = 50
var hover_y_band_tolerance = 2
var picked_point : Vector2
var point_range = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2.ZERO
	if player == null:
		print("bruh the shooter enemy doesn't have a player skull emoji")
		player = self
	curr_state = ShooterEnemyStates.HOVER

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(delta)
	
#	if (cos(rotation) < 0) :
#		$Icon.set_flip_h(true)
#	else:
#		$Icon.set_flip_h(false)
# idk why but this isn't working rn, isn't flipping the image

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

# does not work rn for some reason
func hover(delta):
	if abs(position.x - player.position.x - hover_distance) < hover_band_tolerance || abs(position.x - player.position.x + hover_distance) < hover_band_tolerance :
		if ($PickPoint.is_stopped()) :
			$PickPoint.start()
			var topLim = -point_range if position.y > player.position.y - hover_y_band_tolerance else 0
			var botLim = point_range if position.y < player.position.y + hover_y_band_tolerance else 0
			picked_point = Vector2(position.x + rng.randi_range(-point_range, point_range), position.y + rng.randi_range(topLim, botLim))
		accelerate_in_dir(position - picked_point, delta)
	elif (position.x > player.position.x and position.x < player.position.x + hover_distance) or position.x < player.position.x - hover_distance:
		accelerate_in_dir(Vector2.RIGHT * 75, delta)
	else:
		accelerate_in_dir(Vector2.LEFT * 75, delta)
	slow_down(0.05, delta)

func attack(delta):
	pass

func cooldown(delta):
	pass

func rotate_toward(delta, speed = 1, pos : Vector2 = player.position, isDir : bool = false) :
	# wow I hate how I wrote this, if isDir is true, then pos is taken as a direction vector instead of a position to turn toward
	var angle
	if isDir :
		angle = -pos.angle_to( Vector2.from_angle(rotation) )
	else :
		angle = -(position - pos).angle_to( Vector2.from_angle(rotation) ) 
	
	rotate((angle if abs(angle) < PI else angle + (2 * PI * -sign(angle))) * delta * speed)

func accelerate_in_dir(dir : Vector2, delta, limit : float = speed_limit):
	velocity += (dir * delta)
	velocity = velocity.limit_length(limit)

func move(delta):
	position += velocity * speed_multiplier

func slow_down(friction : float, delta : float) -> void:
	velocity *= pow(friction, delta)

func _on_body_entered(body):
	if body == player :
		#idk what to do in the situation
		# TODO Damage the player
		# TODO Damage the player but less
		# TODO detect getting damaged by player
		pass
