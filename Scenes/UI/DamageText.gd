extends Marker2D

@onready var tween = get_tree().create_tween()
var velocity = Vector2(0,0)

var rand = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = Vector2(rand.randi_range(-15, 15), rand.randi_range(-15, 15))
	rand.randomize()
	velocity = Vector2(0, 30)
	tween.tween_property($Label, "modulate:a", 0, 0.75)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position -= velocity * delta
	


func _on_timer_timeout():
	self.queue_free()
