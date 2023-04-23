extends Node2D

@export var projectile: PackedScene
@export var cooldown = 0.1
@onready var cooldown_timer = $Cooldown
var bullet = load("res://Scenes/Objects/bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown_timer.wait_time = cooldown

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_pressed("player_shoot"):
		fire()

func fire():
	if(!cooldown_timer.time_left):
		var direction = Vector2(get_parent().direction, 0)
		var b = bullet.instantiate()
		b.direction = direction
		var b2 = Area2D.new()
		add_child(b)
		cooldown_timer.start()
