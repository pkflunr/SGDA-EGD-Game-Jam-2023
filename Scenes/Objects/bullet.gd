extends Area2D

@export var speed = 1000
@export var projectile_lifetime = 0.5
@export var damage = 5
var direction = Vector2(1, 0)

func _ready():
	$Lifetime.wait_time = projectile_lifetime
	$Lifetime.start()

func _physics_process(delta):
	position = position + speed * direction * delta	

func _on_lifetime_timeout():
	self.queue_free()
	
func _on_body_entered(body):
	# collision behavior
	pass # Replace with function body.


func _on_area_entered(area):
	if "health" in area:
		print("yeah")
		area.health -= damage
		self.queue_free()
