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
#Walk speed
@export var base_walk_speed = 350.0

var health
var max_health
var armor
var magic_resist
var dodge_chance
var attack_damage
var ability_damage
var attack_speed
var cooldown_reduction
var health_regen
var walk_speed = base_walk_speed

var state = "alert" #"moving", "attacking"

#touchables, but these values are intended behavior. Touch speed if needed.

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
var ableToAttack = true

func _ready():
	update_stats(true)
	$State.text = state
	navigation_agent.simplify_path = true
	navigation_agent.path_desired_distance = 5.0
	navigation_agent.target_desired_distance = 30.0
	#navigation_agent.debug_enabled = true
	navigation_agent.set_path_max_distance(2.0)

func _process(delta):
	selectionLogic()
	$Label.set_text("Target = " +  str(attackTarget))
	update_stats(false)
	
	#health regen
	health += health_regen / 5.0 * delta

#true if want to recalculate the stats from the beginning
func update_stats(start) -> void:
	if start:
		max_health = base_health
		if health == null:
			health = base_health
		armor = base_armor
		attack_damage = base_attack_damage
		magic_resist = base_magic_resist
		dodge_chance = base_dodge_chance
		health_regen = base_health_regen
		attack_speed = base_attack_speed
		ability_damage = base_ability_damage
		cooldown_reduction = base_cooldown_reduction
		walk_speed = base_walk_speed
	
	var healthBar = $Control/Control/HealthBar
	
	healthBar.max_value = max_health
	healthBar.value = health
	
	#1 at 100, 0 at 0
	var healthBarPercent = healthBar.value / healthBar.max_value
	
	var colorRed = 0
	var colorGreen = 400
	colorGreen = lerp(0, 400, healthBarPercent)
	colorRed = lerp(255, 0, healthBarPercent)
	var fill_stylebox = StyleBoxFlat.new()
	fill_stylebox.bg_color = Color(colorRed/255, colorGreen/255, 0)
	fill_stylebox.border_width_right = 5
	fill_stylebox.corner_radius_bottom_left = 3
	fill_stylebox.corner_radius_top_left = 3

# Apply it as a theme override for the fill part
	healthBar.add_theme_stylebox_override("fill", fill_stylebox)

	$AttackCooldownTimer.set_wait_time(1.0 / attack_speed)

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
	$"State".text = state + " Targets : " + str(potentialTargets.size()) + " attackMoveLoc = " + str(attackMoveLocation)
	
	#if attack-moving, attack Enemy as they enter range.
	if attackMoveLocation != Vector2.ZERO:
		if !potentialTargets.is_empty():
			attackTarget = get_closest_unit(potentialTargets)
			state = "attacking"
			path_to(position)
			if navigation_agent.is_navigation_finished():
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
		velocity = current_agent_position.direction_to(next_path_position) * walk_speed
		
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
	if arr.is_empty():
		return null
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
	#print("Selected")
	isSelected = true
	selectionBox.visible = true

func deSelect() -> void:
	#print("deSelected")
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

func _on_attack_cooldown_timer_timeout() -> void:
	ableToAttack = true
