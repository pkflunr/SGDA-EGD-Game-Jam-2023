extends CanvasLayer

var is_paused = false
var cooldown = false

func set_paused(value : bool):
	cooldown = true
	visible = value
	is_paused = value
	get_tree().paused = is_paused
	set_process_input(is_paused)
	
	if is_paused:
		$Control/BoxContainer/VBoxContainer/Resume.grab_focus()
	else:
		$Control.release_focus()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_resume_pressed():
	set_paused(false)


func _on_restart_pressed():
	set_paused(false)
	get_tree().reload_current_scene()

func _on_exit_pressed():
	set_paused(false)
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		set_paused(false)
		
func _on_timer_timeout():
	cooldown = false


