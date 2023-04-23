extends Node2D

enum {TOP,BOTTOM,LEFT,RIGHT}

@export var room_grid_dimensions:Vector2i
@export var room_size = 1792 # assumes rooms are square
@onready var parallax_background = $ParallaxBackground

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_level()
	$Player.camera_2d.limit_left = 0
	$Player.camera_2d.limit_top = 0
	
	$Player.camera_2d.limit_right = room_size * room_grid_dimensions.x
	$Player.camera_2d.limit_bottom = room_size * room_grid_dimensions.y
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parallax_background.scroll_offset = -$Player.position


func generate_level():
	# temp:
	# for now we're just making a list of 25 dummy rooms
	# in the future we should make this a randomized rist of actual rooms
	var room_scene = preload("res://Scenes/Level/room_layout_2.tscn")
	var room_array2 = []
	for x in range(room_grid_dimensions.x * room_grid_dimensions.y):
		room_array2.append(room_scene.instantiate())
	
	var room_array = []
	for x in range(5):
		room_array.append(preload("res://Scenes/Level/room_layout_1.tscn").instantiate())
		room_array.append(preload("res://Scenes/Level/room_layout_2.tscn").instantiate())
		room_array.append(preload("res://Scenes/Level/room_layout_3.tscn").instantiate())
		room_array.append(preload("res://Scenes/Level/room_layout_4.tscn").instantiate())
		room_array.append(preload("res://Scenes/Level/battle_room_layout.tscn").instantiate())
	
	room_array.shuffle()
	
	var placed_room_array:Array[Array] = []
	# place the rooms as needed
	var place_position = Vector2(0,0)
	for x in range(room_grid_dimensions.x):
		placed_room_array.append([])
		for y in range(room_grid_dimensions.y):
			var new_room = room_array.pop_back()
			placed_room_array[x].append(new_room)
			new_room.position = place_position
			add_child(new_room)
			place_position.x += room_size
		place_position.y += room_size
		place_position.x -= room_size * room_grid_dimensions.x
	
	print(str(placed_room_array))
	# and now it is time to run randomized prims, wooo....
	
	# place all walls
	# we represent a wall as a list of two vector2s corresponding to the connections
	var placed_walls = []
	# for each point:
	for x in range(room_grid_dimensions.x):
		for y in range(room_grid_dimensions.y):
			var pos = Vector2i(x,y)
			# top connection
			var top_neighbor = Vector2i(x,y-1)
			if (top_neighbor.y >= 0) and not placed_walls.has([top_neighbor,pos]):
				placed_walls.append([top_neighbor,pos])
			var bottom_neighbor = Vector2i(x,y+1)
			if bottom_neighbor.y < room_grid_dimensions.y and not placed_walls.has([pos,bottom_neighbor]):
				placed_walls.append([pos,bottom_neighbor])
			var left_neighbor = Vector2i(x-1,y)
			if (left_neighbor.x >= 0) and not placed_walls.has([left_neighbor,pos]):
				placed_walls.append([left_neighbor,pos])
			var right_neighbor = Vector2i(x+1,y)
			if right_neighbor.x < room_grid_dimensions.x and not placed_walls.has([pos,right_neighbor]):
				placed_walls.append([pos,right_neighbor])
	
	print(str(placed_walls))
	print(str(placed_walls.size()))
	
	
	# initial node is one of the four corners; 
	var possible_initial_nodes = [Vector2i(0,0),Vector2i(0,room_grid_dimensions.y - 1),Vector2i(room_grid_dimensions.x - 1,0),Vector2i(room_grid_dimensions.x - 1,room_grid_dimensions.y - 1)]
	possible_initial_nodes.shuffle()
	var initial_node = possible_initial_nodes.pop_back()
	var visited = []
	visited.append(initial_node)
	
	var wall_list = []
	# add its walls to a list
	for wall in placed_walls:
		if wall.has(initial_node):
			wall_list.append(wall)
	print(str(wall_list))
	# grab a random wall
	var last_visited_pos = initial_node
	while not wall_list.is_empty():
		var random_wall = wall_list[randi() % wall_list.size()]
		print("selected random wall " + str(random_wall))
		# if only one of its two positions is visited...
		var num_visited = 0
		var visited_pos = Vector2(-1,-1) # only relevant if num_visited == 1
		for position in random_wall:
			if position in visited:
				num_visited += 1
				visited_pos = position
		if num_visited == 1:
			# there is surely a better way to do this...
			var temp = random_wall.duplicate()
			temp.erase(visited_pos)
			var neighbor = temp.pop_front()
			placed_walls.erase(random_wall)
			visited.append(neighbor)
			for wall in placed_walls:
				if wall.has(neighbor):
					wall_list.append(wall)
			# experimental
			# remember last visited room
			last_visited_pos = neighbor
		wall_list.erase(random_wall)
		
	# place player and spawn room
	placed_room_array[initial_node.x][initial_node.y].marked = true
	# remove old room
	placed_room_array[initial_node.x][initial_node.y].queue_free()
	# replace with new room
	var spawn_room = preload("res://Scenes/Level/spawn_room.tscn").instantiate()
	spawn_room.position = Vector2(room_size * initial_node.y,room_size * initial_node.x)
	add_child(spawn_room)
	placed_room_array[initial_node.x][initial_node.y] = spawn_room
	$Player.position = placed_room_array[initial_node.x][initial_node.y].global_position + Vector2(room_size/2,room_size/2)
	
	
	# place end goal and end goal room
	placed_room_array[last_visited_pos.x][last_visited_pos.y].marked = true
	# remove old room
	placed_room_array[last_visited_pos.x][last_visited_pos.y].queue_free()
	# replace with new room
	var queen_room = preload("res://Scenes/Level/queen_room.tscn").instantiate()
	queen_room.position = Vector2(room_size * last_visited_pos.y,room_size * last_visited_pos.x)
	add_child(queen_room)
	placed_room_array[last_visited_pos.x][last_visited_pos.y] = queen_room
	$EndGoal.position = placed_room_array[last_visited_pos.x][last_visited_pos.y].global_position + Vector2(room_size/2,room_size/2)
	print(str(placed_walls))
	print(str(placed_walls.size()))
	
	# enable all of the inner maze walls
	for wall in placed_walls:
		# if the wall is horizontal:
		if wall[0].x == wall[1].x:
			# enable the left room's right wall
			placed_room_array[wall[0].x][wall[0].y].active_walls = placed_room_array[wall[0].x][wall[0].y].active_walls | (1 << RIGHT)
			# and the right room's left wall
			placed_room_array[wall[1].x][wall[1].y].active_walls = placed_room_array[wall[1].x][wall[1].y].active_walls | (1 << LEFT)
		# otherwise, if it's vertical:
		else:
			# enable the top room's bottom wall
			placed_room_array[wall[0].x][wall[0].y].active_walls = placed_room_array[wall[0].x][wall[0].y].active_walls | (1 << BOTTOM)
			# and the bottom room's top wall
			placed_room_array[wall[1].x][wall[1].y].active_walls = placed_room_array[wall[1].x][wall[1].y].active_walls | (1 << TOP)
	# and enable all the border walls
	# top:
	for room in placed_room_array[0]:
		room.active_walls = room.active_walls | (1 << TOP)
	# bottom:
	for room in placed_room_array[room_grid_dimensions.y - 1]:
		room.active_walls = room.active_walls | (1 << BOTTOM)
	# left and right:
	for x in range(room_grid_dimensions.x):
		placed_room_array[x][0].active_walls = placed_room_array[x][0].active_walls | (1 << LEFT)
		placed_room_array[x][room_grid_dimensions.y-1].active_walls = placed_room_array[x][room_grid_dimensions.y-1].active_walls | (1 << RIGHT)
