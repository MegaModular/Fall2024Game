extends RigidBody2D

@export var level = 1

#Game Variables
#damage applied on every attack, physical. 
@export var base_attack_damage = 20.0
#ability damage multiplier
@export var base_ability_damage = 100.0
#basic attack speed in attacks per second
@export var base_attack_speed = 0.5
#base max health
@export var base_health = 100.0
#base armor. Armor reduces a % of physical damage. Max is 75
@export var base_armor = 0.0
#base magic resist. Magic resist reduces a % of magic damage. Max is 75
@export var base_magic_resist = 0.0
#base chance to dodge. Max 50.
@export var base_dodge_chance = 0.0
#health regen per 5 seconds.
@export var base_health_regen = 2.5
#base cooldown reduction for ability. Max 50 (0.5)
@export var base_cooldown_reduction = 0.0

var health
var armor
var magic_resist
var dodge_chance
var attack_damage
var ability_damage
var attack_speed
var cooldown_reduction
var health_regen
var walk_speed

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
var attackMoveLocation = Vector2.ZERO

func _ready():
	update_stats()
	$State.text = state
	navigation_agent.simplify_path = true
	navigation_agent.path_desired_distance = 5.0
	navigation_agent.target_desired_distance = 30.0
	#navigation_agent.debug_enabled = true
	navigation_agent.set_path_max_distance(2.0)

func _process(_delta):
	selectionLogic()
	$Label.set_text("Target = " +  str(attackTarget))

func update_stats() -> void:
	health = base_health
	armor = base_armor
	magic_resist = base_magic_resist
	dodge_chance = base_dodge_chance
	health_regen = base_health_regen

func tryToTarget(enemy):
	if isSelected:
		attackTarget = enemy
		if !potentialTargets.has(enemy):
			path_to(enemy.position)
			return
		state = "attacking"

#updates navAgent to path to this new position
func path_to(loc : Vector2):
	location = loc
	navigation_agent.target_position = location

#when attackMoveLocation is set to Vector2.ZERO, then hero is not attackMoving.
func attack_move_to(loc: Vector2):
	attackMoveLocation = loc
	path_to(attackMoveLocation)

func _physics_process(_delta: float):
	#Debug
	$"State".text = state + " Potential Targets : " + str(potentialTargets.size()) + " attackMoveLoc = " + str(attackMoveLocation)
	
	#if attack-moving, attack Enemy as they enter range.
	if attackMoveLocation != Vector2.ZERO:
		if !potentialTargets.is_empty():
			attackTarget = get_closest_unit(potentialTargets)
			state = "attacking"
			path_to(position)
			return
		else:
			path_to(attackMoveLocation)
	
	#do base movement if path exists and no current target to attackMove to.
	if !navigation_agent.is_navigation_finished():
		state = "moving"
		set_linear_damp(1.5)
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		#print(current_agent_position.direction_to(next_path_position))
		velocity = current_agent_position.direction_to(next_path_position) * defaultSpeed * 4
		
		apply_force(velocity)
	#stop at the end of path, and if there is an available target in range then automatically start attacking.
	else:
		state = "alert"
		set_linear_damp(slowDownDamping)
		if !potentialTargets.is_empty():
			attackTarget = get_closest_unit(potentialTargets)
			state = "attacking"
	#if target exists and is in range, stop and start attacking
	if potentialTargets.has(attackTarget) && attackMoveLocation == Vector2.ZERO:
		#stop
		path_to(position)
		state = "attacking"

func get_closest_unit(arr):
	var closest = arr[0]
	var closestDistance = closest.position.distance_to(position)
	for x in arr:
		var distance = x.position.distance_to(position)
		#print(distance)
		if distance < closestDistance:
			closest = x
			closestDistance = closest.position.distance_to(position)
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

func onEnemyKilled(enemy):
	if enemy == attackTarget:
		attackTarget = null

func _on_enemy_left(body: Node2D) -> void:
	if potentialTargets.has(body):
		potentialTargets = cleanArray(potentialTargets)
		potentialTargets.erase(body)
		print("Left")
