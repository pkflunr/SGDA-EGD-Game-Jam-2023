extends Control

func _ready():
	$CenterContainer/VBoxContainer/SpeedrunButton.set_text("Speedrun Timer: On" if Globals.speedrun_timer else "Speedrun Timer: Off")
	$CenterContainer/VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Level/level.tscn")

func _on_exit_button_pressed():
	get_tree().quit()


func _on_speedrun_button_pressed():
	Globals.speedrun_timer = not Globals.speedrun_timer
	$CenterContainer/VBoxContainer/SpeedrunButton.set_text("Speedrun Timer: On" if Globals.speedrun_timer else "Speedrun Timer: Off")
