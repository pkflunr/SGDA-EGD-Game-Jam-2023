@tool
extends Room


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (active_walls & (1 << TOP)):
		for i in range(12,16):
			for j in range(0,12):
				tile_map.set_cell(0,Vector2i(i,j),TILE_ID,Vector2i(0,0))
	else:
		for i in range(12,16):
			for j in range(0,12):
				tile_map.set_cell(0,Vector2i(i,j))
	if (active_walls & (1 << BOTTOM)):
		for i in range(12,16):
			for j in range(16,28):
				tile_map.set_cell(0,Vector2i(i,j),TILE_ID,Vector2i(0,0))
	else:
		for i in range(12,16):
			for j in range(16,28):
				tile_map.set_cell(0,Vector2i(i,j))
	if (active_walls & (1 << LEFT)):
		for i in range(12,16):
			for j in range(0,12):
				tile_map.set_cell(0,Vector2i(j,i),TILE_ID,Vector2i(0,0))
	else:
		for i in range(12,16):
			for j in range(0,12):
				tile_map.set_cell(0,Vector2i(j,i))
	if (active_walls & (1 << RIGHT)):
		for i in range(12,16):
			for j in range(16,28):
				tile_map.set_cell(0,Vector2i(j,i),TILE_ID,Vector2i(0,0))
	else:
		for i in range(12,16):
			for j in range(16,28):
				tile_map.set_cell(0,Vector2i(j,i))
