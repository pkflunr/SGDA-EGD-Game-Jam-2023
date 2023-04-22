extends Node2D

@onready var enemy : CharacterBody2D = get_node("..")

# Called when the node enters the scene tree for the first time.
func _ready():
	if "health" in enemy:
		$barOutline/hpBar.max_value = enemy.health
		$barOutline.anchor_left = 0.5
		$barOutline.anchor_right = 0.5
		$barOutline.anchor_top = 0.5
		$barOutline.anchor_bottom = 0.5
		$barOutline.offset_left = -enemy.health / 2
		$barOutline.offset_right = enemy.health / 2
		$barOutline.offset_top = -30 / 2
		$barOutline.offset_bottom = 30 / 2
	else :
		print(enemy.name + " does not have a health field but an hp bar was attached to it")
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$barOutline/hpBar.value -= ($barOutline/hpBar.value - enemy.health) * 0.02
