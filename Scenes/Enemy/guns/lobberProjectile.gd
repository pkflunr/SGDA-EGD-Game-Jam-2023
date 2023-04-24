extends Area2D

@export var projectile_lifetime = 0.75
@export var damage = 10
@export var fall_accel = 1800

@export var bullet : PackedScene = load("res://Scenes/Enemy/guns/enemyBasicBullet.tscn")

var direction = Vector2(1, 0)
var fading = false

func _ready():
	$Lifetime.wait_time = projectile_lifetime
	$Lifetime.start()
	$frames.play("flying")

func _physics_process(delta):
	if !fading and $Lifetime.time_left < 0.25 :
		fading = true
		$AnimationPlayer.play("fade")
	position.x += direction.x * delta
	position.y += direction.y * delta
	direction.y += fall_accel * delta
	$Sprite2D.rotation = direction.angle()

func explode(numberOfShots): # shoots a bunch of bullets in a circl
	var angle_offset = RandomNumberGenerator.new().randf_range(0, 2 * PI)
	for n in numberOfShots: # Do the following code for each bullet spawned
		var newBullet = bullet.instantiate() # instantiate a new bullet
		newBullet.projectile_lifetime = 0.25
		newBullet.speed = 500
		# this angle will be used to rotate a number of things. it'll make a pretty circle
		var rotationAngle = Vector2.from_angle(PI * 2 / numberOfShots * n + angle_offset)
		# rotate the bullet's travel direction
		
		newBullet.position = position + rotationAngle * 20 # prevents you from eating up all of the bullets
		
		newBullet.direction = rotationAngle
		get_parent().add_child(newBullet)

	queue_free()

func _on_lifetime_timeout():
	explode(6)

func _on_body_entered(body):
	if "health" in body:
		if body.has_method("hurt"):
			body.hurt(damage)
		else :
			body.health -= damage
		explode(3) # not super punishing if you get hit and end up soaking up a lot
	queue_free()
