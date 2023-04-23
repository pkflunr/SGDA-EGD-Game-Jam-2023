@tool
extends Room



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if (active_walls & (1 << TOP)):
		#for i in range(12,16):
			#tile_map.set_cell(0,Vector2i(i,0),1,Vector2i(0,0))
		tile_map.set_cell(0,Vector2i(12,1),TILE_ID,Vector2i(0,0))
		tile_map.set_cell(0,Vector2i(13,1),SLOPE_ID,Vector2i(0,0),UPPER_LEFT_ID)
		tile_map.set_cell(0,Vector2i(14,1),SLOPE_ID,Vector2i(0,0),UPPER_RIGHT_ID)
		tile_map.set_cell(0,Vector2i(15,1),TILE_ID,Vector2i(0,0))
		tile_map.set_cell(0,Vector2i(12,2),SLOPE_ID,Vector2i(0,0),UPPER_LEFT_ID)
		tile_map.set_cell(0,Vector2i(15,2),SLOPE_ID,Vector2i(0,0),UPPER_RIGHT_ID)
	else:
		for i in range(12,16):
			tile_map.set_cell(0,Vector2i(i,1))
			tile_map.set_cell(0,Vector2i(i,2))
	if (active_walls & (1 << BOTTOM)):
		tile_map.set_cell(0,Vector2i(12,26),TILE_ID,Vector2i(0,0))
		tile_map.set_cell(0,Vector2i(13,26),SLOPE_ID,Vector2i(0,0),BOTTOM_LEFT_ID)
		tile_map.set_cell(0,Vector2i(14,26),SLOPE_ID,Vector2i(0,0),BOTTOM_RIGHT_ID)
		tile_map.set_cell(0,Vector2i(15,26),TILE_ID,Vector2i(0,0))
		tile_map.set_cell(0,Vector2i(12,25),SLOPE_ID,Vector2i(0,0),BOTTOM_LEFT_ID)
		tile_map.set_cell(0,Vector2i(15,25),SLOPE_ID,Vector2i(0,0),BOTTOM_RIGHT_ID)
	else:
		for i in range(12,16):
			pass
			tile_map.set_cell(0,Vector2i(i,26))
			tile_map.set_cell(0,Vector2i(i,25))
	if (active_walls & (1 << LEFT)):
		tile_map.set_cell(0,Vector2i(1,12),TILE_ID,Vector2i(0,0))
		tile_map.set_cell(0,Vector2i(1,13),SLOPE_ID,Vector2i(0,0),UPPER_LEFT_ID)
		tile_map.set_cell(0,Vector2i(1,14),SLOPE_ID,Vector2i(0,0),BOTTOM_LEFT_ID)
		tile_map.set_cell(0,Vector2i(1,15),TILE_ID,Vector2i(0,0))
		tile_map.set_cell(0,Vector2i(2,12),SLOPE_ID,Vector2i(0,0),UPPER_LEFT_ID)
		tile_map.set_cell(0,Vector2i(2,15),SLOPE_ID,Vector2i(0,0),BOTTOM_LEFT_ID)
	else:
		for i in range(12,16):
			tile_map.set_cell(0,Vector2i(1,i))
			tile_map.set_cell(0,Vector2i(2,i))
	if (active_walls & (1 << RIGHT)):
		tile_map.set_cell(0,Vector2i(26,12),TILE_ID,Vector2i(0,0))
		tile_map.set_cell(0,Vector2i(26,13),SLOPE_ID,Vector2i(0,0),UPPER_RIGHT_ID)
		tile_map.set_cell(0,Vector2i(26,14),SLOPE_ID,Vector2i(0,0),BOTTOM_RIGHT_ID)
		tile_map.set_cell(0,Vector2i(26,15),TILE_ID,Vector2i(0,0))
		tile_map.set_cell(0,Vector2i(25,12),SLOPE_ID,Vector2i(0,0),UPPER_RIGHT_ID)
		tile_map.set_cell(0,Vector2i(25,15),SLOPE_ID,Vector2i(0,0),BOTTOM_RIGHT_ID)
	else:
		for i in range(12,16):
			tile_map.set_cell(0,Vector2i(25,i))
			tile_map.set_cell(0,Vector2i(26,i))
