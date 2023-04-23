extends Area2D

@export var speed = 800
@export var projectile_lifetime = 1.5
@export var damage = 10
var direction = Vector2(1, 0)
var fading = false

func _ready():
	$Lifetime.wait_time = projectile_lifetime
	$Lifetime.start()
	$Sprite2D.rotation = direction.angle()

func _physics_process(delta):
	if !fading and $Lifetime.time_left < 0.25 :
		fading = true
		$AnimationPlayer.play("fade")
	position = position + speed * direction * delta

func _on_lifetime_timeout():
	self.queue_free()

func _on_body_entered(body):
	if "health" in body:
		if body.has_method("hurt"):
			body.hurt(damage)
		else :
			body.health -= damage
	queue_free()
