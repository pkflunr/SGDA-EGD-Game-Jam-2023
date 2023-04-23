extends "res://Scenes/Enemy/shooterBase.gd"

func _ready():
	super._ready()
	shooter = $enemyShooter

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#
#	move()
#	match curr_state:
#		ShooterEnemyStates.HOVER:
#			hover(delta)
#		ShooterEnemyStates.ATTACK:
#			attack(delta)
#		ShooterEnemyStates.VULNERABLE:
#			vulnerable(delta)

func hover(delta):
	if player == null:
		shake_smooth(delta, 100)
		return
	look_at_player_horizontal()
	accelerate_in_dir((picked_point - position) * 2, delta, 25)
	slow_down(delta, 0.2)
	unscaledVelocity.x *= pow(0.5, delta)
	if !$HoverTime.time_left :
		enter_attack()

func generate_hover_point():
	if player != null:
		var topLim = -y_point_range if position.y > player.position.y - hover_y_band_tolerance else 0
		var botLim = y_point_range if position.y < player.position.y + hover_y_band_tolerance else 0
		var offset = rng.randi_range(topLim, botLim)
		picked_point = Vector2(player.position.x + (hover_distance if position.x > player.position.x else -hover_distance) + rng.randi_range(-x_point_range, x_point_range), position.y + offset)

func attack(delta):
	look_at_player_horizontal()
	shooter.fire(player.position - position)
	enter_hover_mode()

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
