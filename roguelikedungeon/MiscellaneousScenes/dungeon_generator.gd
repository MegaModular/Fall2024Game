extends Node2D

const TILE_SIZE = 64

var startingRoomSize = 8
var minRoomSize = 12
var maxRoomSize = 25

#Chance for a non-important connection to be generated from 0-1
var roomConnectionChance = 0.2

#Size of generated paths
var pathSize = 2

#Minimum distance a room can generate from another room
var minimumGenDistance = 30 

#Minimum Distance for a room to generate to automatically connect to another
var minAutoConnectDistance = 80

#100 - double monster density
var additionalMonsterDensity = 200

#S - 8
#M - 10
#L - 15
#XL - 25
#XXL - 40
#XXXL - 60
var numberOfRooms = 25
#double the size is the generated area.
#S-L: 75
#XL : 100
#XXL-XXXL - 120
const MAXDUNGEONSIZE = 100

#lower, faster. Don't use number less than 2.
var crossRoomSize = 3

#Make array of random values, which the vector2 distance between two rooms is no greater than 10.
#The dungeon will be a new scene in which "room" has different values, and randomly generates
#based upon a desired size. These rooms will also have connections to any room within 10
#distance of one another.

@onready var roomScene = preload("res://MiscellaneousScenes/room.tscn")
@onready var enemySpawnerScene = preload("res://EnemyScenes/enemy_spawner_instance.tscn")

var lastRoomPos = Vector2.ZERO

var loopRooms = []
var generated_dungeon_graph = []
#Rooms that are not singlehandedyle dependent
var potentialInterestRooms = []
#Rooms that should not be far away from the center and minimal connections to. Good place for important things.
var endRooms = []
#If endroom is empty, then we have to randomly place the exit / rewards around the map.

func _ready():
	randomize()
	rotation = randf_range(0, PI/2)
	
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

#Function that calls functions in order. Generates the rooms first, then overrides with a path
#ensuring that a viable path will always generate.
func generate_dungeon(numRooms: int) -> void:
	generated_dungeon_graph = generate_dungeon_graph(numRooms)
	drawRooms(generated_dungeon_graph)
	carveOutPath(generated_dungeon_graph)
	drawLoopRooms(loopRooms)
	markSpecialRooms(generated_dungeon_graph)
	populateRooms()
	print("Dungeon Generated.\nRooms : " + str(generated_dungeon_graph.size()) + "\nMonster Density : " + str((100 + additionalMonsterDensity))
	+ "\nWith " + str(Globals.numEnemies) + " monsters spawned.\nNumber of Potential Rooms: " + str(potentialInterestRooms.size())
	+ "\nAnd with " + str(endRooms.size()) + " potential end rooms.")

#Makes the dungeon itself in the dungeon[] array. Adds the respective connections that are required.
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

#these basically clamp any one room from generating farther than maxgendistance
#and smaller than mingendistance from any other room in the already generated dungeon
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

#Make the path between rooms.
func carveOutPath(dungeonArr):
	#Make walker walk and carve from each connection
	for room in dungeonArr:
		#room.toString()
		if room.centerConnection != null:
			carveSinglePath(room.roomCoords, room.centerConnection)
		for connection in room.connections:
			if randf_range(0, 1) < roomConnectionChance:
				carveSinglePath(room.roomCoords, connection)

#Called by carveOutPath, makes a single path between two Vector2i points on the grid.
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
		for i in range(-pathSize, pathSize):
			for j in range(-pathSize, pathSize):
				$TileMapLayer.set_cell(startingPos + Vector2i(i,j), 0, Vector2i(0,1))
	while(startingPos.y != endPos.y):
		#print(startingPos)
		if startingPos.y > endPos.y:
			startingPos.y -= 1
			$TileMapLayer.set_cell(startingPos, 0,Vector2i(0, 1))
		if startingPos.y < endPos.y:
			startingPos.y += 1
			$TileMapLayer.set_cell(startingPos, 0,Vector2i(0, 1))
		for i in range(-pathSize, pathSize):
			for j in range(-pathSize, pathSize):
				$TileMapLayer.set_cell(startingPos + Vector2i(i,j), 0, Vector2i(0,1))

#Makes the rooms.
func drawRooms(dungeonArr):
	for room in dungeonArr:
		var x = randf_range(0, 1)
		if room.isConnectedToCenter == false:
			print("Room is not connected to center.")
			room.toString()
			dungeonArr.erase(room)
			#$TileMapLayer.set_cell(room.roomCoords, 0,Vector2i(0, 1))
		else:
			#Debugging, baiscally marks the center of the room.
			$TileMapLayer.set_cell(room.roomCoords, 0,Vector2i(1, 0))
		
		if x < 0.25:
			drawCircleRoom(room)
		elif x < 0.5:
			#drawLoopRoom(room)
			loopRooms.append(room)
		elif x < 0.75:
			drawCrossRoom(room)
		else:
			drawSquareRoom(room)
		
		
	return

#Due to how I coded it, loop rooms have to be generated after everything else. This function does that.
func drawLoopRooms(aloopRooms):
	for room in aloopRooms:
		drawLoopRoom(room)

#these functions generate various types of rooms.
func drawSquareRoom(room):
	var offset = Vector2i(room.roomSize.x /2, room.roomSize.y / 2)
	for x in room.roomSize.x:
		for y in room.roomSize.y:
			$TileMapLayer.set_cell(room.roomCoords + Vector2i(x,y) - offset, 0,Vector2i(0, 1))

func drawCrossRoom(room):
	#Make square
	if abs(room.roomSize.x - room.roomSize.y) > 0:
		if room.roomSize.x > room.roomSize.y:
			room.roomSize.y = room.roomSize.x
		room.roomSize.x = room.roomSize.y
	
	var offset = Vector2i(room.roomSize.x /2, room.roomSize.y / 2)
	var overrideTile = false
	for x in room.roomSize.x:
		for y in room.roomSize.y:
			var roomOffset = Vector2i(x,y)
			var tileCoords = room.roomCoords + roomOffset - offset 
			overrideTile = false
			var crossSize = crossRoomSize
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
	#Make square
	if abs(room.roomSize.x - room.roomSize.y) > 0:
		if room.roomSize.x > room.roomSize.y:
			room.roomSize.y = room.roomSize.x
		room.roomSize.x = room.roomSize.y
	
	var offset = Vector2i(room.roomSize.x /2, room.roomSize.y / 2)
	for x in room.roomSize.x:
		for y in room.roomSize.y:
			$TileMapLayer.set_cell(room.roomCoords + Vector2i(x,y) - offset, 0,Vector2i(0, 1))
	
	for x in room.roomSize.x/3:
		for y in room.roomSize.y/3:
			$TileMapLayer.set_cell(room.roomCoords + Vector2i(x,y) - offset/3, 0,Vector2i(0, 0))

func drawCircleRoom(room):
	#Make square
	if abs(room.roomSize.x - room.roomSize.y) > 0:
		if room.roomSize.x > room.roomSize.y:
			room.roomSize.y = room.roomSize.x
		room.roomSize.x = room.roomSize.y
	
	var offset = Vector2i(room.roomSize.x /2, room.roomSize.y / 2)
	var overrideTile = false
	for x in room.roomSize.x:
		for y in room.roomSize.y:
			var roomOffset = Vector2i(x,y)
			overrideTile = false
			#Cancel out non-circle tiles. Does this by measuring the distance between origin and tile and if it is greater than
			#the radius then override it.
			if (room.roomCoords + offset).distance_to(roomOffset + room.roomCoords) >= (room.roomSize.y /2.0):
				overrideTile = true
			#print(str((room.roomCoords + offset).distance_to(roomOffset + room.roomCoords)) +" : " + str((room.roomSize.y /1.9)))
			var tileCoords = room.roomCoords + roomOffset - offset 
			if overrideTile:
				$TileMapLayer.set_cell(tileCoords, 0,Vector2i(0, 0))
			else:
				$TileMapLayer.set_cell(tileCoords, 0,Vector2i(0, 1))

#Checks to see if a room has another that requires it to exist in order to connect to the center.
func hasCenterDependency(roomInQuestion, dungeonArr):
	for room in dungeonArr:
		if room.centerConnection == roomInQuestion.roomCoords:
			return true
	return false

func markSpecialRooms(dungeonArr):
	for room in dungeonArr:
		if !hasCenterDependency(room, dungeonArr):
			potentialInterestRooms.append(room)
			if room.connectionDistanceToCenter > 2:
				endRooms.append(room)
				for x in range(-1, 1):
					for y in range(-1, 1):
						$TileMapLayer.set_cell(room.roomCoords + Vector2i(x,y), 0, Vector2i(1, 0))
					
				
			$TileMapLayer.set_cell(room.roomCoords, 0, Vector2i(1, 0))

#Adds chests/ enemy spawners to each dungeon room.
func populateRooms():
	var cells = $TileMapLayer.get_used_cells_by_id(0, Vector2i(0, 1), -1)
	for cell in cells:
		if cell.distance_to(Vector2i(0,0)) > 15:
			if randf_range(0, 1) < 0.005 + (0.005 * additionalMonsterDensity/100):
				var enemySpawner = enemySpawnerScene.instantiate()
				enemySpawner.position = $TileMapLayer.map_to_local(cell)
				add_child(enemySpawner)
	
	return
