extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		# this should in the future send you to a victory screen
		get_tree().reload_current_scene()