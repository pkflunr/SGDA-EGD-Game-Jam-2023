extends "res://Scenes/Enemy/enemyBase.gd"

@export var hover_distance = 400

enum ShooterEnemyStates {
	HOVER,
	ATTACK,
	DYING,
	VULNERABLE,
	RECOVER,
	DEATH
}

var shooter : Node2D

var hover_y_band_tolerance = 400 
var picked_point : Vector2
var x_point_range = 30
var y_point_range = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	dying_state = ShooterEnemyStates.DYING
	vulnerable_state = ShooterEnemyStates.VULNERABLE
	normal_state = ShooterEnemyStates.RECOVER

var prev_frame_player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player == null :
		prev_frame_player = player
		idle(delta)
	else :
		if prev_frame_player != player:
			prev_frame_player = player
			enter_hover_mode()
		match curr_state:
			ShooterEnemyStates.HOVER:
				hover(delta)
			ShooterEnemyStates.ATTACK:
				attack(delta)
			ShooterEnemyStates.VULNERABLE:
				vulnerable(delta)
			ShooterEnemyStates.RECOVER:
				recover(delta)

func hover(delta):
	accelerate_in_dir((picked_point - position) * 2, delta, 25)
	slow_down(delta, 0.2)
	unscaledVelocity.x *= pow(0.5, delta)
	move()

	look_at_player_horizontal()
	if !$HoverTime.time_left :
		enter_attack()

func generate_hover_point():
	var topLim = -y_point_range if position.y > player.position.y - hover_y_band_tolerance else 0
	var botLim = y_point_range if position.y < player.position.y + hover_y_band_tolerance else 0
	var offset = rng.randi_range(topLim, botLim)
	picked_point = Vector2(player.position.x + (hover_distance if position.x > player.position.x else -hover_distance) + rng.randi_range(-x_point_range, x_point_range), position.y + offset)

func attack(delta):
	if is_instance_valid(player) and is_instance_valid(shooter):
		shooter.fire(player.position - position)
	else:
		print("something fucked up")
	move()
	enter_hover_mode()

func recover(delta):
	orient_self_gradual(delta)
	if abs(cos(sprite.rotation)) > 0.95 :
		force_horizontal_orientation()
		enter_hover_mode()
	move()

func enter_hover_mode() :
	$HoverTime.start()
	$PickPoint.start()
	generate_hover_point()
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
