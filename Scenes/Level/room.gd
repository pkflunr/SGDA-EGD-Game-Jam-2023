@tool
extends Node2D
class_name Room
# room size is 28 * 28 tiles
enum {TOP,BOTTOM,LEFT,RIGHT}
@onready var tile_map = $TileMap

var enemies_in_room:Array = []

@export_flags("TOP","BOTTOM","LEFT","RIGHT") var active_walls = 0
@export var marked = false

const TILE_ID = 1
const SLOPE_ID = 0
const BOTTOM_LEFT_ID = 0
const BOTTOM_RIGHT_ID = 1
const UPPER_RIGHT_ID = 3
const UPPER_LEFT_ID = 4
@onready var room_area = $RoomArea

# Called when the node enters the scene tree for the first time.
func _ready():
	if room_area != null:
		for body in room_area.get_overlapping_bodies():
			if body.is_in_group("enemies"):
				enemies_in_room.append(body)

func _process(delta):
	if (active_walls & (1 << TOP)):
		for i in range(12,16):
			tile_map.set_cell(0,Vector2i(i,0),1,Vector2i(0,0))
	else:
		for i in range(12,16):
			tile_map.set_cell(0,Vector2i(i,0))
	if (active_walls & (1 << BOTTOM)):
		for i in range(12,16):
			tile_map.set_cell(0,Vector2i(i,27),1,Vector2i(0,0))
	else:
		for i in range(12,16):
			tile_map.set_cell(0,Vector2i(i,27))
	if (active_walls & (1 << LEFT)):
		for i in range(12,16):
			tile_map.set_cell(0,Vector2i(0,i),1,Vector2i(0,0))
	else:
		for i in range(12,16):
			tile_map.set_cell(0,Vector2i(0,i))
	if (active_walls & (1 << RIGHT)):
		for i in range(12,16):
			tile_map.set_cell(0,Vector2i(27,i),1,Vector2i(0,0))
	else:
		for i in range(12,16):
			tile_map.set_cell(0,Vector2i(27,i))

func _on_room_area_body_entered(body):
	if body.is_in_group("player"):
		for enemy in enemies_in_room:
			if "aggro_target" in enemy:
				enemy.aggro_target = body
			if "player" in enemy:
				enemy.player = body
	elif body.is_in_group("enemy"):
		if not enemies_in_room.has(body):
			print("room made a friend")
			enemies_in_room.append(body)
