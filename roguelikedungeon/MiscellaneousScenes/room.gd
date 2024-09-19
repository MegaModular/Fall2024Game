extends Node2D

class_name Room

var roomSize : Vector2
var roomPos : Vector2
var connections = []

func _ready():
	$Label.text = str(connections)
	$Panel.scale = roomSize

func setScale(scal : Vector2):
	roomSize = scal
	$Panel.size = scal * 20
	$Panel.position = (scal * 5) / 2

func setPos(pos: Vector2):
	roomPos = pos

func getRoomPos() -> Vector2:
	return roomPos

func addConnection(newRoom : Node2D) -> void:
	connections.append(newRoom)
	$Label.text = str(connections)

func removeConnection(newRoom : Node2D)-> void:
	if connections.has(newRoom):
		connections.erase(newRoom)
