extends RigidBody2D

@export var level = 1

@export var heroClass : String
@export var abilitySelected : String

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
@export var base_walk_speed = 200.0
#lifesteal
@export var base_omnivamp = 0.0

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
var omnivamp

var bonus_health = 0
var bonus_armor = 0
var bonus_magic_resist = 0
var bonus_dodge_chance = 0
var bonus_attack_damage = 0
var bonus_ability_damage = 0
var bonus_attack_speed = 0
var bonus_cooldown_reduction = 0
var bonus_health_regen = 0
var bonus_walk_speed = 0
var bonus_omnivamp = 0.0

var state = "alert" #"moving", "attacking"

var lastAbilityCast = null
var lastAbilityLevel = 1

#touchables, but these values are intended behavior. Touch speed if needed.

#how far the unit strays from the path (0(max) - 1(none))
@export var pathHardness = 0.75
var slowDownDamping = 5.0

#Used if the character is ranged to set the $Vision.


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

var isDead : bool = false

var frameCount = 0

var moveOrder = 0

func _ready():
	update_stats()
	navigation_agent.simplify_path = true
	navigation_agent.path_desired_distance = 30.0
	navigation_agent.target_desired_distance = 30.0
	navigation_agent.debug_enabled = false


func _process(delta):
	if Globals.isPaused:
		return
	selectionLogic()
	#$Label.set_text("Target = " +  str(attackTarget))
	#$"State".text = state 

	update_health_bar()
	
	#health regen
	health += health_regen / 5.0 * delta

func heal(amount):
	health += amount
	clamp(health, 0, max_health)

func applyDamage(damage : float, type): #0 - Physical, 1 - Magic, 2 - True
	var text = Globals.damageTextReference.instantiate()
	var x = randf_range(0,1)
	if x < dodge_chance/100:
		text.damageAmount = "Dodged"
		text.position = position
		$"../../ParticleHolder".add_child(text)
		return
	
	if type == 0:
		damage *= 1.0 - armor/100.0
		text.damageType = 0
	if type == 1:
		damage *= 1 - magic_resist/100.0
		text.damageType = 1
	if type == 2:
		text.damageType = 2
	
	damage *= randf_range(0.8, 1.2)
	damage = snapped(damage, 1)
	
	health -= damage;

	text.damageAmount = damage
	text.position = position
	$"../../../ParticleHolder".add_child(text)
	update_health_bar()

func update_health_bar() -> void:
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

func update_stats() -> void:
	#base stats
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
	omnivamp = base_omnivamp
	
	max_health += bonus_health
	armor += bonus_armor
	attack_damage += bonus_attack_damage
	magic_resist += bonus_magic_resist
	dodge_chance += bonus_dodge_chance
	health_regen += bonus_health_regen
	attack_speed += bonus_attack_speed
	ability_damage += bonus_ability_damage
	cooldown_reduction += bonus_cooldown_reduction
	walk_speed += bonus_walk_speed
	omnivamp += bonus_omnivamp
	
	attack_speed = clamp(attack_speed, 0.25, 5)
	update_health_bar()
	$State.text = heroClass.capitalize()
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

var storedVelocity = Vector2.ZERO
var recentlyUnpaused : bool = false

func _physics_process(delta: float):
	if Globals.isPaused:
		recentlyUnpaused = true
		set_linear_damp(9999)
		if !$AttackCooldownTimer.is_paused():
			$AttackCooldownTimer.set_paused(true)
		return
	#When unpaused, restore velocity
	elif recentlyUnpaused:
		set_linear_damp(1.5)
		if $AttackCooldownTimer.is_paused():
			$AttackCooldownTimer.set_paused(false)
		recentlyUnpaused = false
	
	#do base movement if path exists and no current target to attackMove to.
	if !navigation_agent.is_navigation_finished():
		if !state == "attacking":
			state = "moving"
		set_linear_damp(1.5)
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		#print(current_agent_position.direction_to(next_path_position))
		#velocity = current_agent_position.direction_to(next_path_position) * walk_speed
		self.position = self.position.move_toward(next_path_position, delta * walk_speed)
		#apply_force(velocity)
	#stop at the end of path, and if there is an available target in range then automatically start attacking.

	#Give one frame to each of these for calculating shit
	frameCount += 1
	if frameCount % 4 != moveOrder:
		return
	
	#Attack if a target can exist and not moving
	if navigation_agent.is_navigation_finished():
		state = "alert"
		set_linear_damp(slowDownDamping)
		if !potentialTargets.is_empty() && attackTarget == null:
			attackTarget = get_closest_unit(potentialTargets)
			state = "attacking"
	#Stores velocity if paused

	
	#if attack-moving, attack Enemy as they enter range.
	if attackMoveLocation != Vector2.ZERO:
		if !potentialTargets.is_empty():
			attackTarget = get_closest_unit(potentialTargets)
			state = "attacking"
			path_to(position)
			return
		else:
			path_to(attackMoveLocation)

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
	if Input.is_action_just_pressed("lmb"):
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
	mouseInArea = true

func _on_mouse_shape_exited(_shape_idx: int) -> void:
	mouseInArea = false

func cleanArray(array):

	var newArr = []
	if array.is_empty():
		return newArr
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
	potentialTargets = cleanArray(potentialTargets)
	if potentialTargets.has(body):
		potentialTargets.erase(body)

func _on_attack_cooldown_timer_timeout() -> void:
	ableToAttack = true
