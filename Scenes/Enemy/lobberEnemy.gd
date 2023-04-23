extends "res://Scenes/Enemy/shooterEnemy.gd"

func _ready():
	super._ready()
	shooter = $lobberGun

func generate_hover_point():
	var topLim = -y_point_range if position.y > player.position.y - hover_y_band_tolerance else 0
	var botLim = y_point_range if position.y < player.position.y + hover_y_band_tolerance / 8 else 0
	var offset = rng.randi_range(topLim, botLim)
	picked_point = Vector2(player.position.x + (hover_distance if position.x > player.position.x else -hover_distance) + rng.randi_range(-x_point_range, x_point_range), position.y + offset)
