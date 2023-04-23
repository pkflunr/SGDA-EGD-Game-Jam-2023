extends Node

var enemies_killed = 0
var enemies_captured = 0
var global_timer = 0

var speedrun_timer = false
var timer_running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if timer_running:
		global_timer += delta

func start_game():
	global_timer = 0
	enemies_killed = 0
	enemies_captured = 0
	timer_running = true

func end_game():
	timer_running = false
	
func convert_time(raw_time): # function to convert time (counted from delta) to format MM'SS"mmm
	var ms = fmod(raw_time,1)*1000
	var sec = fmod(raw_time,60)
	var mins = fmod(raw_time, 60*60) / 60
		
	var str_time = "%02d'%02d\"%03d" % [mins, sec, ms]
	return str_time
