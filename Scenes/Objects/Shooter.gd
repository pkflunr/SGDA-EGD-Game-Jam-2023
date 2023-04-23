extends Node2D

var projectile: PackedScene = load("res://Scenes/Objects/bullet.tscn")
@export var cooldown = 0.15
@onready var cooldown_timer = $Cooldown

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown_timer.wait_time = cooldown

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_pressed("player_shoot"):
		fire()

func fire():
	if(!cooldown_timer.time_left) and get_parent().player_can_input:
		var direction = Vector2(get_parent().direction, 0)
		var b = projectile.instantiate()
		b.direction = direction
		b.get_node("Sprite2D").flip_h = true if sign(direction.x) == -1 else false
		b.position = get_parent().position
		var b2 = Area2D.new()
		get_parent().get_parent().add_child(b)
		cooldown_timer.start()
