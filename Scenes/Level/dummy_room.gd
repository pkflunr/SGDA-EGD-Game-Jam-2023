@tool
extends Node2D

enum {TOP,BOTTOM,LEFT,RIGHT}

@export_flags("TOP","BOTTOM","LEFT","RIGHT") var active_walls = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (active_walls & (1 << TOP)):
		$Top.visible = true
	else:
		$Top.visible = false
	if (active_walls & (1 << BOTTOM)):
		$Bottom.visible = true
	else:
		$Bottom.visible = false
	if (active_walls & (1 << LEFT)):
		$Left.visible = true
	else:
		$Left.visible = false
	if (active_walls & (1 << RIGHT)):
		$Right.visible = true
	else:
		$Right.visible = false
