extends Node2D

var bullet : PackedScene = preload("res://Scenes/Enemy/guns/enemyBasicBullet.tscn")
@export var cooldown = 0.2
@onready var cooldown_timer = $Cooldown

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown_timer.wait_time = cooldown

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func fire(directionTarget : Vector2) -> bool:
	if(!cooldown_timer.time_left):
		if directionTarget != Vector2.ZERO:
			var b = bullet.instantiate()
			b.direction = directionTarget.normalized()
			b.position = get_node("..").position
			get_tree().get_root().add_child(b)
			cooldown_timer.start()
		return true
	return false
