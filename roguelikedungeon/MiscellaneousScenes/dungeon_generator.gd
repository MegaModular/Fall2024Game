extends Node2D

var startingRoomSize = 8

var minRoomSize = 12
var maxRoomSize = 25

#Chance for a non-important connection to be generated from 0-1
var roomConnectionChance = 0

#Size of generated paths
var pathSize = 2

#Minimum distance a room can generate from another room
var minimumGenDistance = 30 

#Minimum Distance for a room to generate to automatically connect to another
var minAutoConnectDistance = 80

var numberOfRooms = 2
#double the size is the generated area.
const MAXDUNGEONSIZE = 100

#Make array of random values, which the vector2 distance between two rooms is no greater than 10.
#The dungeon will be a new scene in which "room" has different values, and randomly generates
#based upon a desired size. These rooms will also have connections to any room within 10
#distance of one another.

@onready var roomScene = preload("res://MiscellaneousScenes/room.tscn")

var lastRoomPos = Vector2.ZERO

var generated_dungeon_graph = []
#Rooms that are not singlehandedyle dependent
var potentialInterestRooms = []
#Rooms that should not be far away from the center and minimal connections to. Good place for important things.
var endRooms = []

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
	generate_dungeon(numberOfRooms)
	print(endRooms)

func generate_dungeon(numRooms: int) -> void:
	generated_dungeon_graph = generate_dungeon_graph(numRooms)
	carveOutPath(generated_dungeon_graph)
	drawRooms(generated_dungeon_graph)
	markSpecialRooms(generated_dungeon_graph)

func generate_dungeon_graph(numRooms: int):
	var dungeon = []
	var x = roomScene.instantiate()
	
	#Base starting room
	x.roomCoords = Vector2i(0, 0)
	x.roomSize = Vector2i(1, 1)
	x.isConnectedToCenter = true
	x.connectionDistanceToCenter = 0
	add_child(x)
	dungeon.append(x)
	
	while(numRooms > dungeon.size()):
		var roomSizeX = randi_range(minRoomSize, maxRoomSize)
		var roomSizeY = randi_range(minRoomSize, maxRoomSize)
		
		var roomLocX = randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE)
		var roomLocY = randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE)
		
		while isRoomTooClose(dungeon, Vector2i(roomLocX, roomLocY)) == false && isRoomTooFar(dungeon, Vector2i(roomLocX, roomLocY)) == false:
			roomLocX = randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE)
			roomLocY = randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE)
		
		
		x = roomScene.instantiate()
		x.roomCoords = Vector2i(roomLocX, roomLocY)
		x.roomSize = Vector2i(roomSizeX, roomSizeY)
		
		#add connections, and each room will only have one connection as such that only one hallway will generate.
		for room in dungeon:
			if room.roomCoords.distance_to(x.roomCoords) < minAutoConnectDistance:
				if room.isConnectedToCenter && x.isConnectedToCenter == false:
					x.isConnectedToCenter = true
					x.centerConnection = room.roomCoords
					x.connectionDistanceToCenter = room.connectionDistanceToCenter + 1
				else:
					x.addConnection(room.roomCoords)
		if x.isConnectedToCenter:
			add_child(x)
			dungeon.append(x)
	return dungeon

func isRoomTooClose(dungeonArr, newRoomPos : Vector2i) -> bool:
	for room in dungeonArr:
		if newRoomPos.distance_to(room.roomCoords) < minimumGenDistance:
			return false
	return true

func isRoomTooFar(dungeonArr, newRoomPos : Vector2i) -> bool:
	for room in dungeonArr:
		if newRoomPos.distance_to(room.roomCoords) < minAutoConnectDistance:
			return false
	return true

func carveOutPath(dungeonArr):
	#Make walker walk and carve from each connection
	for room in dungeonArr:
		#room.toString()
		if room.centerConnection != null:
			carveSinglePath(room.roomCoords, room.centerConnection)
		for connection in room.connections:
			if randf_range(0, 10) < roomConnectionChance:
				carveSinglePath(room.roomCoords, connection)
	

func carveSinglePath(startingPos, endPos) -> void:
	#print(str(startingPos) + ", " + str(endPos))
	while(startingPos.x != endPos.x):
		#print(startingPos)
		if startingPos.x > endPos.x:
			startingPos.x -= 1
			$TileMapLayer.set_cell(startingPos, 0,Vector2i(0, 1))
		if startingPos.x < endPos.x:
			startingPos.x += 1
			$TileMapLayer.set_cell(startingPos, 0,Vector2i(0, 1))
		for i in range(-pathSize, pathSize-1):
			for j in range(-pathSize, pathSize-1):
				$TileMapLayer.set_cell(startingPos + Vector2i(i,j), 0, Vector2i(0,1))
	while(startingPos.y != endPos.y):
		#print(startingPos)
		if startingPos.y > endPos.y:
			startingPos.y -= 1
			$TileMapLayer.set_cell(startingPos, 0,Vector2i(0, 1))
		if startingPos.y < endPos.y:
			startingPos.y += 1
			$TileMapLayer.set_cell(startingPos, 0,Vector2i(0, 1))
		for i in range(-pathSize, pathSize-1):
			for j in range(-pathSize, pathSize-1):
				$TileMapLayer.set_cell(startingPos + Vector2i(i,j), 0, Vector2i(0,1))

func drawRooms(dungeonArr):
	for room in dungeonArr:
		if room.isConnectedToCenter == false:
			print("Room is not connected to center.")
			room.toString()
			dungeonArr.erase(room)
			#$TileMapLayer.set_cell(room.roomCoords, 0,Vector2i(0, 1))
		else:
			$TileMapLayer.set_cell(room.roomCoords, 0,Vector2i(1, 0))
		drawCrossRoom(room)
	return

func drawSquareRoom(room):
	var offset = Vector2i(room.roomSize.x /2, room.roomSize.y / 2)
	for x in room.roomSize.x:
		for y in room.roomSize.y:
			$TileMapLayer.set_cell(room.roomCoords + Vector2i(x,y) - offset, 0,Vector2i(0, 1))

func drawCrossRoom(room):
	var offset = Vector2i(room.roomSize.x /2, room.roomSize.y / 2)
	var overrideTile = false
	for x in room.roomSize.x:
		for y in room.roomSize.y:
			var roomOffset = Vector2i(x,y)
			var tileCoords = room.roomCoords + roomOffset - offset 
			var crossSizeScalar = randi_range(3,6)
			overrideTile = false
			var crossSize = 3
			#Top-left
			if (x < room.roomSize.x / crossSize) && (y < room.roomSize.y / crossSize):
				overrideTile = true
			#Bot-left
			if (x < room.roomSize.x / crossSize) && (y > (crossSize-1) * (room.roomSize.y / crossSize)):
				overrideTile = true
			#Top-right
			if (x > (crossSize-1)*(room.roomSize.x /crossSize)) && (y < room.roomSize.y / crossSize):
				overrideTile = true
			#Bot-right
			if (x > (crossSize-1)*(room.roomSize.x /crossSize)) && (y > (crossSize-1) * (room.roomSize.y / crossSize)):
				overrideTile = true
			if overrideTile:
				$TileMapLayer.set_cell(tileCoords, 0,Vector2i(0, 0))
			else:
				$TileMapLayer.set_cell(tileCoords, 0,Vector2i(0, 1))
			
			

func drawLoopRoom(room):
	return

func drawCircleRoom(room):
	return

func drawLRoom(room):
	return

func hasCenterDependency(roomInQuestion, dungeonArr):
	for room in dungeonArr:
		if room.centerConnection == roomInQuestion.roomCoords:
			return true
	return false

func markSpecialRooms(dungeonArr):
	for room in dungeonArr:
		if !hasCenterDependency(room, dungeonArr):
			potentialInterestRooms.append(room)
			if room.connectionDistanceToCenter > 3:
				endRooms.append(room)
			$TileMapLayer.set_cell(room.roomCoords, 0, Vector2i(1, 0))
