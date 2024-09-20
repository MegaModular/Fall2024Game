extends Node2D

var startingRoomSize = 6

var minRoomSize = 6
var maxRoomSize = 16

var minimumGenDistance = 20 

var minAutoConnectDistance = 25

var numberOfRooms = 15

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
	#Generate World
	for i in range(-MAXDUNGEONSIZE*2, MAXDUNGEONSIZE*2):
		for j in range(-MAXDUNGEONSIZE*2, MAXDUNGEONSIZE*2):
			$TileMapLayer.set_cell(Vector2(i,j), 0,Vector2i(0, 0))
	#Generate Starting Room
	for i in range(-startingRoomSize, startingRoomSize):
		for j in range(-startingRoomSize, startingRoomSize):
			$TileMapLayer.set_cell(Vector2i(i,j), 0, Vector2i(0,1))
	#Generate Rooms
	#carveSinglePath(Vector2(0,0), Vector2(-10,10))
	generated_dungeon_graph = generate_dungeon_graph(numberOfRooms)
	drawRooms(generated_dungeon_graph)
	carveOutPath(generated_dungeon_graph)
	


func generate_dungeon_graph(numRooms: int):
	var dungeon = []
	var x = roomScene.instantiate()
	
	#Base starting room
	x.roomCoords = Vector2i(0, 0)
	x.roomSize = Vector2i(1, 1)
	x.isConnectedToCenter = true
	add_child(x)
	dungeon.append(x)
	
	while(numRooms > dungeon.size()):
		var roomSizeX = randi_range(minRoomSize, maxRoomSize)
		var roomSizeY = randi_range(minRoomSize, maxRoomSize)
		
		var roomLocX = randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE)
		var roomLocY = randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE)
		
		while isRoomTooClose(dungeon, Vector2i(roomLocX, roomLocY)) == false && isRoomTooFar(dungeon, Vector2i(roomLocX, roomLocY)):
			roomLocX = randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE)
			roomLocY = randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE)
		
		
		x = roomScene.instantiate()
		x.roomCoords = Vector2i(roomLocX, roomLocY)
		x.roomSize = Vector2i(roomSizeX, roomSizeY)
		
		#add connections, and each room will only have one connection as such that only one hallway will generate.
		for room in dungeon:
			if room.roomCoords.distance_to(x.roomCoords) < minAutoConnectDistance:
				x.addConnection(room.roomCoords)
				if room.isConnectedToCenter:
					x.isConnectedToCenter = true
		
		add_child(x)
		dungeon.append(x)
		
		#dungeon[dungeon.size()-1].toString()
	
	return dungeon

func isRoomTooClose(dungeonArr, newRoomPos : Vector2i) -> bool:
	for room in dungeonArr:
		if newRoomPos.distance_to(room.roomCoords) < minimumGenDistance:
			return false
	return true

func isRoomTooFar(dungeonArr, newRoomPos : Vector2i) -> bool:
	for room in dungeonArr:
		if newRoomPos.distance_to(room.roomCoords) > minAutoConnectDistance:
			return false
	return true

func carveOutPath(dungeonArr):
	var walker = Vector2i.ZERO
	#Make walker walk and carve from each connection
	for room in dungeonArr:
		room.toString()
		for connection in room.connections:
			carveSinglePath(room.roomCoords, connection)
	

func carveSinglePath(startingPos, endPos) -> void:
	#print(str(startingPos) + ", " + str(endPos))
	while(startingPos.x != endPos.x):
		print(startingPos)
		if startingPos.x > endPos.x:
			startingPos.x -= 1
			$TileMapLayer.set_cell(startingPos, 0,Vector2i(0, 1))
		if startingPos.x < endPos.x:
			startingPos.x += 1
			$TileMapLayer.set_cell(startingPos, 0,Vector2i(0, 1))
		for i in range(-1, 1):
			for j in range(-1, 1):
				$TileMapLayer.set_cell(startingPos + Vector2i(i,j), 0, Vector2i(0,1))
	while(startingPos.y != endPos.y):
		print(startingPos)
		if startingPos.y > endPos.y:
			startingPos.y -= 1
			$TileMapLayer.set_cell(startingPos, 0,Vector2i(0, 1))
		if startingPos.y < endPos.y:
			startingPos.y += 1
			$TileMapLayer.set_cell(startingPos, 0,Vector2i(0, 1))
		for i in range(-1, 1):
			for j in range(-1, 1):
				$TileMapLayer.set_cell(startingPos + Vector2i(i,j), 0, Vector2i(0,1))
	return



func drawRooms(dungeonArr):
	for room in dungeonArr:
		if room.isConnectedToCenter == false:
			dungeonArr.erase(room)
		$TileMapLayer.set_cell(room.roomCoords, 0,Vector2i(0, 1))
		#for x in room.roomSize.x:
		#	for y in room.roomSize.y:
		#		$TileMapLayer.set_cell(room.roomCoords + Vector2i(x,y), 0,Vector2i(0, 1))
	return
