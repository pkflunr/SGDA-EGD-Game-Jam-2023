extends Area2D

@export var speed = 2000
@export var projectile_lifetime = 0.4
@export var damage = 5
@export var fall_accel = 1800

var bullet : PackedScene = load("res://Scenes/Objects/bullet.tscn")
var direction : Vector2 = Vector2.RIGHT
var fading = false

func _ready():
	$scuff.play("flying")
	$Lifetime.wait_time = projectile_lifetime
	$Lifetime.start()

func _physics_process(delta):
	if !fading and $Lifetime.time_left < 0.25 :
		fading = true
		$AnimationPlayer.play("fade")
	rotation = direction.angle()
	position.x += speed * direction.x * delta
	position.y += direction.y * delta
	direction.y += fall_accel * delta

func _on_lifetime_timeout():
	explode(6)
	self.queue_free()

func _on_body_entered(body):
	if "health" in body:
		if body.has_method("damage"):
			body.damage(damage)
			explode(6)
		else :
			body.health -= damage
			explode(6)
	else :
		explode(6)

#func _on_area_entered(area):
#	if "health" in area:
#		area.health -= damage
#		explode(3)

func explode(numberOfShots): # shoots a bunch of bullets in a circl
	var angle_offset = RandomNumberGenerator.new().randf_range(0, 2 * PI)
	for n in numberOfShots: # Do the following code for each bullet spawned
		var newBullet = bullet.instantiate() # instantiate a new bullet
		newBullet.projectile_lifetime = 0.25
		newBullet.speed = 500
		# this angle will be used to rotate a number of things. it'll make a pretty circle
		var rotationAngle = Vector2.from_angle(PI * 2 / numberOfShots * n + angle_offset)
		# rotate the bullet's travel direction
		newBullet.rotation = rotationAngle.angle()
		newBullet.position = position + rotationAngle * 20 # prevents you from eating up all of the bullets
		
		newBullet.direction = rotationAngle
		get_parent().add_child(newBullet)

	queue_free()
