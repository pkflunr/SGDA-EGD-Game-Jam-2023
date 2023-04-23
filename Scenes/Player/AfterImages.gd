extends Marker2D

@onready var tween = get_tree().create_tween()
@onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	tween.tween_property($Sprite, "modulate", Color(self.modulate.r, self.modulate.g, self.modulate.b, 0), 0.2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	queue_free()
