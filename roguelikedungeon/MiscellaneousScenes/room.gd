extends Node2D

var roomSize : Vector2i
var roomCoords : Vector2i
var connections = []
var isConnectedToCenter : bool = false
var centerConnection : Vector2i
var connectionDistanceToCenter : int


func addConnection(newRoom : Vector2i) -> void:
	connections.append(newRoom)
	#$Label.text = str(connections)

func removeConnection(newRoom : Vector2i)-> void:
	if connections.has(newRoom):
		connections.erase(newRoom)

func toString():
	print("Room: " + str(self) + "\nSize = " + str(roomSize) + "\nCoordinates: "+ str(roomCoords)+"\nConnections: " + str(connections))
	print("Connection To Center: " + str(centerConnection) + ", Distance = " + str(connectionDistanceToCenter))
	return
