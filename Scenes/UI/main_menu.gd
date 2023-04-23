extends Control

func _ready():
	$CenterContainer/VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Level/level.tscn")
	MusicPlayer.play_bee_battle()

func _on_exit_button_pressed():
	get_tree().quit()
