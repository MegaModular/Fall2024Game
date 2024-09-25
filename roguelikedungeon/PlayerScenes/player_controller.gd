#Script contains logic for player controls of moving / manipulating the heros.
extends Node2D

#touchable
const FULLTAPTIME = 0.25
var doubleTapTime = 0.25

var mousePos = Vector2()

var mousePosGlobal = Vector2()
var start = Vector2()
var startV = Vector2()
var end = Vector2()
var endV = Vector2()
var isDragging = false

#FUCK YOU STOP THROWING THIS FUCKING ERROR THESE ARE USED
signal area_selected
signal start_move_selection

var units = []

@onready var moveParticles = preload("res://Particles/move_particles.tscn")
@onready var panel = $"UI/Panel"

func _ready():
	$Camera/HUD.hideHUD()
	connect("area_selected", Callable(self,"_on_area_selected"))
	units = get_tree().get_nodes_in_group("unit")
	#print(units)

@onready var hud = $Camera/HUD

#Handles input for displaying and closing menus. Pauses and Unpauses the game.

func HUDInput():
	#exit menu
	if Input.is_action_just_pressed("esc"):
		#quit menu show
		if !Globals.isPaused:
			hud.showHUD()
			Globals.isPaused = true
			return
		#quit menu hide
		if Globals.isPaused:
			hud.hideAllHUD()
			Globals.isPaused = false
			return
		#skill Menu
	if Input.is_action_just_pressed("t"):
		if hud.quitMenuShown:
			return
		if hud.skillMenuShown:
			hud.hideSKILL()
			if !hud.isHUDShown():
				Globals.isPaused = false
			return
		hud.showSKILL()
		Globals.isPaused = true
		if !hud.isHUDShown():
			Globals.isPaused = false
		return
	
	if Input.is_action_just_pressed("i"):
		if hud.quitMenuShown:
			return
		if hud.invMenuShown:
			hud.hideINV()
			if !hud.isHUDShown():
				Globals.isPaused = false
			return
		hud.showINV()
		Globals.isPaused = true
		if !hud.isHUDShown():
			Globals.isPaused = false
		return

var quickBandageFix = 0

#Contains drag unit selection, and movement input handling.
func _process(delta):
	if Globals.isPaused:
		return
	dragSelectBoxLogic()
	
	
	if doubleTapTime >= 0:
		doubleTapTime -= delta
	
	#Logic to determine the location of a click and to tell heroes to move while keeping mind of their offset.
	if Input.is_action_just_pressed("rmb") || Input.is_action_just_pressed("a"):
		var center = calculate_center()
		var clickLocation = get_global_mouse_position()
		
		#checks to see if there is an enemy under the cursor. If not, issues a movement command to selected units
		if !Globals.mouseInEnemyArea:
			for hero in $Heroes.get_children():
				if hero._isBodySelected():
					var offsetLocation : Vector2
					if (hero.position.distance_to(center)) > 200.0:
						offsetLocation = clickLocation + (hero.position - center) * 0.3
					else: offsetLocation = clickLocation + (hero.position - center) * 0.5
					var particles = moveParticles.instantiate()
					add_child(particles)
					hero.attackTarget = null
					#attackMove
					if Input.is_action_just_pressed("a"):
						#print("AttackMoved")
						hero.attack_move_to(offsetLocation)
						hero.attackTarget = null
						particles.position = offsetLocation
					#regular Move
					else:
						particles.position = offsetLocation
						hero.attack_move_to(Vector2.ZERO)
						hero.path_to(offsetLocation)
		else:
			quickBandageFix += 1
			if quickBandageFix > 120:
				Globals.mouseInEnemyArea = 0

#Logic for number keys 1-4 to select heroes. 5 to select all, double tap to focus camera on them too.
func keySelectionLogic():
	var heroes = $Heroes.get_children()
	var cam = $Camera
	if Input.is_action_just_pressed("1"):
		if heroes.size() >= 1:
			deselectHeroes()
			heroes[0].Select()
			if doubleTapTime > 0:
				cam.focusOn(heroes[0].position)
				return
			doubleTapTime = FULLTAPTIME
	if Input.is_action_just_pressed("2"):
		if heroes.size() >= 2:
			deselectHeroes()
			heroes[1].Select()
			if doubleTapTime > 0:
				cam.focusOn(heroes[1].position)
				return
			doubleTapTime = FULLTAPTIME
	if Input.is_action_just_pressed("3"):
		if heroes.size() >= 3:
			deselectHeroes()
			heroes[2].Select()
			if doubleTapTime > 0:
				cam.focusOn(heroes[2].position)
				return
			doubleTapTime = FULLTAPTIME
	if Input.is_action_just_pressed("4"):
		if heroes.size() >= 4:
			deselectHeroes()
			heroes[3].Select()
			if doubleTapTime > 0:
				cam.focusOn(heroes[3].position)
				return
			doubleTapTime = FULLTAPTIME
	if Input.is_action_just_pressed("5"):
		for hero in heroes:
			hero.Select()
		if doubleTapTime > 0:
			cam.focusOn(cam.calculate_center())
			return
		doubleTapTime = FULLTAPTIME

#Deselects all heroes.
func deselectHeroes():
	var heroes = $Heroes.get_children()
	for hero in heroes:
		hero.deSelect()

#returns the average location of all the selected heroes.
func calculate_center() -> Vector2:
	var c = Vector2.ZERO
	var count = 0
	for hero in $Heroes.get_children():
		if hero._isBodySelected():
			c += hero.position
			count += 1
	c /= count
	return c

#Logic to determine the location of the box and input handling
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

#Input handling for drag select box.
func _input(event):
	HUDInput()
	keySelectionLogic()
	if event is InputEventMouse:
		mousePos = event.position
		mousePosGlobal = get_global_mouse_position()

#Probably makes the selection box and draws it each frame. Idk tho
func draw_area(s=true):
	panel.size = Vector2(abs(startV.x - endV.x), abs(startV.y - endV.y))
	var pos = Vector2()
	pos.x = min(startV.x,endV.x)
	pos.y = min(startV.y, endV.y)
	panel.position = pos
	panel.size *= int(s)

#Selects units in area. Don't touch this or call it anywhere else
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

#Again, no clue what this does. Dont call it.
func _on_area_selected(_object):
	#print(object)
	var area = []
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	var ut = get_units_in_area(area)
	for u in ut:
		u.Select()
