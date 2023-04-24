extends CanvasLayer

@onready var player = get_parent()
@onready var damage_text = load("res://Scenes/UI/DamageText.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.speedrun_timer:
		$SpeedrunTimer.visible = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$TimeNode/TimeContainer/TimeLabelBox/TimerLabel.set_text("%d" % player.health)
	$lowHPVignette/CanvasLayer/ColorRect.modulate.a = clampf(-(player.health - 30) / 15.0, 0, 1)
	if Globals.speedrun_timer:
		$SpeedrunTimer.set_text("%s" % Globals.convert_time(Globals.global_timer))
#		print("update global timer to " + Globals.convert_time(Globals.global_timer))


func hurt_effect(damage_value : int):
	var dmg = damage_text.instantiate()
	dmg.get_node("Label").set_text("-%d" % damage_value)
	$Emitter.add_child(dmg)
