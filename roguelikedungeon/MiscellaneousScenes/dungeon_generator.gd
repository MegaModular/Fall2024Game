extends Node2D

var minRoomSize = 6
var maxRoomSize = 16

var minimumGenDistance = 200 
var maximumGenDistance = 500

var minAutoConnectDistance = 50

const MAXDUNGEONSIZE = 250

#Make array of random values, which the vector2 distance between two rooms is no greater than 10.
#The dungeon will be a new scene in which "room" has different values, and randomly generates
#based upon a desired size. These rooms will also have connections to any room within 10
#distance of one another.

@onready var roomScene = preload("res://MiscellaneousScenes/room.tscn")

var lastRoomPos = Vector2.ZERO

var generated_dungeon_graph = []

func _ready():
	randomize()
	generated_dungeon_graph = generate_dungeon_graph(15)
	drawRooms(generated_dungeon_graph)
	#print(generated_dungeon_graph)

func generate_dungeon_graph(numRooms: int):
	var dungeon = []
	#Default room
	var r = roomScene.instantiate()
	r.setScale(Vector2(6,6))
	r.setPos(Vector2(0,0))
	dungeon.append(r)
	add_child(r)
	var rooms_generated = 1
	
	lastRoomPos = Vector2.ZERO
	
	while(rooms_generated < numRooms):
		#Generates new coordinates and size
		var newPos = Vector2(randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE), randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE))
		var generated_size = Vector2(randi_range(minRoomSize, maxRoomSize), randi_range(minRoomSize, maxRoomSize))
		#If too close, regenerate room
		for rooms in dungeon:
			if rooms.roomPos.distance_to(newPos) < minimumGenDistance:
				newPos = Vector2(randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE), randi_range(-MAXDUNGEONSIZE, MAXDUNGEONSIZE))
		#if lastRoomPos.distance_to(newPos) < minimumGenDistance:
			
		#If too far, make closer.
		if lastRoomPos.distance_to(newPos) > maximumGenDistance:
			newPos *= 0.75
			floor(newPos)
		
		r = roomScene.instantiate()
		r.setPos(newPos)
		r.setScale(generated_size)
		lastRoomPos = newPos
		dungeon.append(r)
		r.position = r.roomPos * 10
		add_child(r)
		rooms_generated += 1
		for room in dungeon:
			if room.getRoomPos().distance_to(lastRoomPos) < minAutoConnectDistance:
				room.addConnection(dungeon.back())
	return dungeon

func drawRooms(dungeonArr):
	return
	for room in dungeonArr:
		var r = roomScene.instantiate()
		for connection in room.connections:
			r.addConnection(connection)
		r.positon = room.roomPos * 100
		r.scale = room.roomSize
		add_child(r)
