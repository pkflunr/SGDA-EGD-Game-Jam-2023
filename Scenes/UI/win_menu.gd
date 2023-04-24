extends Control

func _ready():
	$CenterContainer/VBoxContainer/BeesContainer/Bees.set_text("%d" % Globals.enemies_captured)
	$CenterContainer/VBoxContainer/TimeContainer/Time.set_text("%s" % Globals.convert_time(Globals.global_timer))
func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")


func _on_button_pressed_2():
	get_tree().change_scene_to_file("res://Scenes/Level/level.tscn")
