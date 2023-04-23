extends Node2D

@export var cooldown = 0.12
@onready var cooldown_timer = $Cooldown
var bullet: PackedScene = load("res://Scenes/Enemy/guns/enemyBasicBullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown_timer.wait_time = cooldown

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func fire(targetVector : Vector2) -> bool:
	#too lazy to quadratic equation my life away so woo I have some dumb approximations here
	if(!cooldown_timer.time_left):
		var b = bullet.instantiate()
		b.direction = targetVector.normalized()
		b.position = get_node("..").position
		get_tree().get_root().add_child(b)
		cooldown_timer.start()
		return true
	return false
