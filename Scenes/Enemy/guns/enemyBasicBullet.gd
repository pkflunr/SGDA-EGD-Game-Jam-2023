extends Area2D

@export var speed = 800
@export var projectile_lifetime = 1.5
@export var damage = 10
var direction = Vector2(1, 0)
var fading = false

func _ready():
	$Shot.play()
	$"splat sprite".modulate.a = 0
	$Lifetime.wait_time = projectile_lifetime
	$Lifetime.start()
	$Sprite2D.rotation = direction.angle()
	$frames.play("flying")

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
		splat()

func splat():
	direction = Vector2.ZERO
	$"splat sprite".modulate.a = 1
	$Sprite2D.modulate.a = 0
	$frames.play("splat")


func _on_frames_animation_finished(anim_name):
	if anim_name == "splat":
		queue_free()
