extends Node2D

var roomSize : Vector2i
var roomCoords : Vector2i
var connections = []

func addConnection(newRoom : Node2D) -> void:
	connections.append(newRoom)
	$Label.text = str(connections)

func removeConnection(newRoom : Node2D)-> void:
	if connections.has(newRoom):
		connections.erase(newRoom)

func toString():
	print("Room: " + str(self) + "\nSize = " + str(roomSize) + "\nCoordinates: "+ str(roomCoords)+"\nConnections: " + str(connections))
	return
