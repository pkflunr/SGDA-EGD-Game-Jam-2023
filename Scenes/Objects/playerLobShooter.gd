extends Node2D

var projectile: PackedScene = load("res://Scenes/Objects/playerLobProjectile.tscn")
@export var cooldown = 0.5
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
		var b = projectile.instantiate()
		
		if get_parent().direction == -1:
			b.direction = Vector2(-1,0).rotated(PI/4)
		else :
			b.direction = Vector2(1,0).rotated(-PI/4)
		b.position = get_parent().position
		get_parent().get_parent().add_child(b)
		cooldown_timer.start()
