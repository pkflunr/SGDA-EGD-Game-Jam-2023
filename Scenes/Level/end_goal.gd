extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		MusicPlayer.play_zombee_birth()
		# this should in the future send you to a victory screen
		get_tree().change_scene_to_file("res://Scenes/UI/win_menu.tscn")
