extends Marker2D

const CAMERA_REACH_X = 150
const CAMERA_REACH_Y = 50

@onready var player = get_parent()
var last_player_velocity : Vector2

func _ready():
	last_player_velocity = player.velocity
	

func _physics_process(delta):
	# HORIZONTAL MOVEMENT
	if abs(player.velocity.x) > 0 and player.input_x:
		if sign(last_player_velocity.x) != sign(position.x):
			position.x = lerp(position.x, 0.0, delta)
		position.x = lerp(self.position.x, (CAMERA_REACH_X*sign(player.velocity.x)), 2 * delta)
	else:
		self.position.x = lerp(self.position.x, 0.0, 0.05)
	
	# VERTICAL MOVEMENT
	if abs(player.velocity.y) > 0 and player.input_y:
		if sign(last_player_velocity.y) != sign(position.y):
			position.y = lerp(position.y, 0.0, delta)
		position.y = lerp(self.position.y, (CAMERA_REACH_Y*-sign(player.velocity.y)), 2 * delta)
	else:
		self.position.y = lerp(self.position.y, 0.0, delta)
	last_player_velocity = player.velocity
