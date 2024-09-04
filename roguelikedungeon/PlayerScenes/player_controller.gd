extends Node2D

var mousePos = Vector2()

var mousePosGlobal = Vector2()
var start = Vector2()
var startV = Vector2()
var end = Vector2()
var endV = Vector2()
var isDragging = false
signal area_selected
signal start_move_selection

var units = []

@onready var panel = $"UI/Panel"

func _ready():
	connect("area_selected", Callable(self,"_on_area_selected"))
	units = get_tree().get_nodes_in_group("unit")
	#print(units)

func _process(_delta):
	dragSelectBoxLogic()
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
	if Input.is_action_just_pressed("rmb"):
		for hero in $Heroes.get_children():
			if hero._isBodySelected():
				hero.path_to(get_global_mouse_position())

func dragSelectBoxLogic():
	if Input.is_action_just_pressed("lmb"):
		start = mousePosGlobal
		startV = mousePos
		isDragging = true
	
	if isDragging:
		end = mousePosGlobal
		endV = mousePos
		draw_area()
	
	if Input.is_action_just_released("lmb"):
		if startV.distance_to(mousePos) > 20:
			end = mousePosGlobal
			endV = mousePos
			isDragging = false
			draw_area(0)
			emit_signal("area_selected", self)
		else:
			end = start
			isDragging = false
			draw_area(0)

func _input(event):
	if event is InputEventMouse:
		mousePos = event.position
		mousePosGlobal = get_global_mouse_position()

func draw_area(s=true):
	panel.size = Vector2(abs(startV.x - endV.x), abs(startV.y - endV.y))
	var pos = Vector2()
	pos.x = min(startV.x,endV.x)
	pos.y = min(startV.y, endV.y)
	panel.position = pos
	panel.size *= int(s)

func get_units_in_area(area):
	#print(area)
	var u = []
	for unit in units:
		if (unit.position.x > area[0].x) and (unit.position.x < area[1].x):
			if (unit.position.y > area[0].y) and (unit.position.y < area[1].y):
				u.append(unit)
				pass
	#print(u)
	return u

func _on_area_selected(object):
	#print(object)
	var area = []
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	var ut = get_units_in_area(area)
	for u in ut:
		u.Select()
