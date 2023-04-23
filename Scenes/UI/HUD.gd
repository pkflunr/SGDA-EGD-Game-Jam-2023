extends CanvasLayer

@onready var player = get_parent()
@onready var damage_text = load("res://Scenes/UI/DamageText.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$TimeNode/TimeContainer/TimeLabelBox/TimerLabel.set_text("%d" % player.health)


func hurt_effect(damage_value : int):
	var dmg = damage_text.instantiate()
	dmg.get_node("Label").set_text("-%d" % damage_value)
	$Emitter.add_child(dmg)
