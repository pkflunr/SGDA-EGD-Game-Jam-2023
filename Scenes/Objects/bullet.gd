extends Area2D

@export var speed = 1000
@export var projectile_lifetime = 0.75
@export var damage = 5
var direction = Vector2(1, 0)
var fading = false

func _ready():
	$Lifetime.wait_time = projectile_lifetime
	$Lifetime.start()

func _physics_process(delta):
	if !fading and $Lifetime.time_left < 0.25 :
		fading = true
		$AnimationPlayer.play("fade")
	position = position + speed * direction * delta	

func _on_lifetime_timeout():
	self.queue_free()
	
func _on_body_entered(body):
	if "health" in body:
		print("right")
		body.health -= damage
		self.queue_free()


func _on_area_entered(area):
	if "health" in area:
		print("yeah")
		area.health -= damage
		self.queue_free()
