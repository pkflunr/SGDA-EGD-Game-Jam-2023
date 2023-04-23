extends Node2D

var bullet : PackedScene = load("res://Scenes/Enemy/guns/lobberProjectile.tscn")
@export var cooldown = 0.12
@onready var cooldown_timer = $Cooldown
var max_vel = 2000

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown_timer.wait_time = cooldown

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func fire(directionTarget : Vector2) -> bool:
	if(!cooldown_timer.time_left):
		var b = bullet.instantiate()
		b.direction = Vector2.from_angle(get_adjusted_angle(directionTarget.angle())) * min(directionTarget.length() * 1.8, max_vel)
		b.position = get_node("..").position
		get_tree().get_root().add_child(b)
		cooldown_timer.start()
		return true
	return false

func get_adjusted_angle(angle) -> float:
	if abs(angle) > PI / 2:
		return -angle_func(-angle + sign(angle) * PI) + sign(angle) * PI
	else:
		return angle_func(angle)

func angle_func(angle) -> float:
	return clampf(1.7562 * sin(angle - 0.463648), -PI/2, PI/2)
