extends Node2D

var minRoomSize = 6
var maxRoomSize = 16

var minimumGenDistance = 200 
var maximumGenDistance = 500

var minAutoConnectDistance = 50

const MAXDUNGEONSIZE = 50

#Make array of random values, which the vector2 distance between two rooms is no greater than 10.
#The dungeon will be a new scene in which "room" has different values, and randomly generates
#based upon a desired size. These rooms will also have connections to any room within 10
#distance of one another.

@onready var roomScene = preload("res://MiscellaneousScenes/room.tscn")

var lastRoomPos = Vector2.ZERO

var generated_dungeon_graph = []

func _ready():
	randomize()
	for i in range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE):
		for j in range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE):
			$TileMapLayer.set_cell(Vector2(i,j), 0,Vector2i(0, 0))
	generated_dungeon_graph = generate_dungeon_graph(15)
	drawRooms(generated_dungeon_graph)


func generate_dungeon_graph(numRooms: int):
	var dungeon = []
	
	while(numRooms > dungeon.size()):
		var roomSizeX = randi_range(minRoomSize, maxRoomSize)
		var roomSizeY = randi_range(minRoomSize, maxRoomSize)
		
		var roomLocX = randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE)
		var roomLocY = randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE)
		var x = roomScene.instantiate()
		x.roomCoords = Vector2i(roomLocX, roomLocY)
		x.roomSize = Vector2i(roomSizeX, roomSizeY)
		add_child(x)
		dungeon.append(x)
		dungeon[dungeon.size()-1].toString()
	return dungeon

func drawRooms(dungeonArr):
	for room in dungeonArr:
		$TileMapLayer.set_cell(room.roomCoords, 0,Vector2i(0, 1))
		room.toString()
	return
