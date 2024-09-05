extends RigidBody2D


var state = "alert" #"moving", "attacking"

#touchables, but these values are intended behavior. Touch speed if needed.
@export var defaultSpeed = 100.0
#how far the unit strays from the path (0(max) - 1(none))
@export var pathHardness = 0.75
var slowDownDamping = 5.0

@export var isSelected : bool = false
var mouseInArea : bool = false

@onready var navigation_agent = $NavAgent
@onready var selectionBox = $Control/Panel

var location : Vector2
var velocity = Vector2.ZERO

var attackTarget = null
var potentialTargets = []

func _ready():
	$State.text = state
	navigation_agent.simplify_path = true
	navigation_agent.path_desired_distance = 5.0
	navigation_agent.target_desired_distance = 30.0
	#navigation_agent.debug_enabled = true
	navigation_agent.set_path_max_distance(2.0)

func _process(_delta):
	selectionLogic()
	$Label.set_text("Target = " +  str(attackTarget))

func tryToTarget(enemy):
	if isSelected:
		attackTarget = enemy
		state = "attacking"

func path_to(loc : Vector2):
	location = loc
	navigation_agent.target_position = location

func _physics_process(_delta: float):
	$"State".text = str(potentialTargets) + state
	#do base movement if target doesnt exist
	if attackTarget == null:
		if !navigation_agent.is_navigation_finished():
			state = "moving"
			set_linear_damp(1.5)
			var current_agent_position: Vector2 = global_position
			var next_path_position: Vector2 = navigation_agent.get_next_path_position()
			if current_agent_position.direction_to(next_path_position):
				pass
			#print(current_agent_position.direction_to(next_path_position))
			velocity = current_agent_position.direction_to(next_path_position) * defaultSpeed * 4
			
			apply_force(velocity)
		else:
			state = "alert"
			set_linear_damp(slowDownDamping)
			if !potentialTargets.is_empty():
				attackTarget = get_closest_unit(potentialTargets)
				state = "attacking"
	else:
		#state = "alert"
		path_to(position)
		

func get_closest_unit(arr):
	var closest = arr[0]
	for x in arr:
		var distance = x.position - position
		print(distance)
		if distance < (closest.position - position):
			closest = x
	return closest

func _isBodySelected():
	return isSelected

func selectionLogic():
	if Input.is_action_pressed("lmb"):
		if Input.is_action_pressed("shift"):
			if mouseInArea: 
				Select()
			if !mouseInArea:
				pass
		else:
			if mouseInArea:
				Select()
			if !mouseInArea:
				deSelect()

func Select() -> void:
	#print("Selected", self)
	isSelected = true
	selectionBox.visible = true

func deSelect() -> void:
	#print("deSelected", self)
	isSelected = false
	selectionBox.visible = false

func _on_mouse_shape_entered(_shape_idx: int) -> void:
	#print("Mouse Detected", self)
	$MouseHover.visible = true
	mouseInArea = true

func _on_mouse_shape_exited(_shape_idx: int) -> void:
	#print("Mouse No Longer Detected", self)
	$MouseHover.visible = false
	mouseInArea = false

func cleanArray(array):
	var newArr = []
	for val in array:
		if is_instance_valid(val):
			newArr.append(val)
	return newArr

func _on_enemy_detected(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		potentialTargets = cleanArray(potentialTargets)
		potentialTargets.append(body)


func _on_enemy_left(body: Node2D) -> void:
	if potentialTargets.has(body):
		potentialTargets = cleanArray(potentialTargets)
		potentialTargets.erase(body)
		
