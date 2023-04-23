extends Node2D

@export var projectile: PackedScene
@export var cooldown = 0.12
@onready var cooldown_timer = $Cooldown
var bullet = load("res://Scenes/Enemy/shooters/enemyBasicBullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown_timer.wait_time = cooldown

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func fire(direction : Vector2) -> bool:
	if(!cooldown_timer.time_left):
		if (!(direction == Vector2.ZERO)):
			var b = bullet.instantiate()
			b.direction = direction.normalized()
			b.position = get_node("..").position
			get_tree().get_root().add_child(b)
			cooldown_timer.start()
		return true
	return false
