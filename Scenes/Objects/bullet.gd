extends Area2D

@onready var bullet_splat = preload("res://Scenes/Objects/bullet_splat.tscn")
@onready var splat_sound = load("res://Sound/SFX/BulletExp.wav")

@export var speed = 1000
@export var projectile_lifetime = 1.5
@export var damage = 5
var direction = Vector2(1, 0)
var fading = false

func _ready():
	$AudioStreamPlayer2D.play()
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
		if body.has_method("damage"):
			body.damage(damage)
		else :
			body.health -= damage
	else:
		var splat = AudioStreamPlayer.new()
		splat.set_stream(splat_sound)
		get_parent().add_child(splat)
		splat.play()
	splat()
	queue_free()

func _on_area_entered(area):
	if "health" in area:
		area.health -= damage
		self.queue_free()

func splat():
	var b = bullet_splat.instantiate()
	b.position = self.position
	get_parent().add_child(b)
