extends CharacterBody2D

#Do target selection here, then make the base melee child and base range child. 
#Then, be able to derive new classes from each, with varying stats and whatnot.
#These will be able to damage player too, but not from this script.

@export var isElite = false
@export var level = 1

#Game Variables
@export var base_health = 50.0
@export var base_armor = 0.0
@export var base_magic_resist = 0.0
@export var base_dodge_chance = 0.0
@export var base_speed = 100
@export var base_attack_damage = 10

@onready var playerReference = $"../../Player/Heroes"
@onready var targetParticlesScene = preload("res://Particles/target_particles.tscn")
@onready var deathParticleScene = preload("res://Particles/enemyDeathParticles.tscn")


var stunTime : float = 0.0

var health
var armor
var magic_resist
var dodge_chance
var walk_speed
var attack_damage

var mouseInArea = false

var direction = Vector2.ZERO

var target = null
var targetInRange : bool = false

var pathUpdateFrames = 20

var frameCount = 0

func _ready():
	pathUpdateFrames += randi_range(100, 200)
	set_physics_process(false)
	set_process(false)
	visible = false
	Globals.numEnemies += 1
	#print(playerReference.get_children())
	walk_speed = base_speed
	health = base_health
	armor = base_armor
	magic_resist = base_magic_resist
	dodge_chance = base_dodge_chance
	attack_damage = base_attack_damage
	if isElite:
		health = base_health * 3
		attack_damage = base_attack_damage * 1.5
		$Label.set_text("Elite")
	updateHealthBar()
	$NavigationAgent2D.debug_enabled = false

#Make this target player if hit.
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
	$"../../ParticleHolder".add_child(text)
	if health <= 0:
		for hero in playerReference.get_children():
			if hero.attackTarget == self:
				hero.attackTarget = hero.get_closest_unit(hero.potentialTargets)
		if Globals.mouseInEnemyArea > 0 && mouseInArea:
			Globals.mouseInEnemyArea = 0
		Globals.numEnemies -= 1
		var dp = deathParticleScene.instantiate()
		dp.position = self.global_position
		$"../../ParticleHolder".add_child(dp)
		queue_free()
	updateHealthBar()

func applyStun(time : float):
	stunTime += time

func _process(delta):
	if Globals.isPaused:
		return
	if stunTime > 0:
		stunTime -= delta
		return


func _input(event):
	#Target Selection Code, from player.
	if Input.is_action_just_pressed("rmb") && mouseInArea:
		for hero in playerReference.get_children():
			hero.tryToTarget(self)
		for hero in playerReference.get_children():
			if hero.attackTarget == self:
				var particles = targetParticlesScene.instantiate()
				add_child(particles)
				return

var storedVelocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if stunTime > 0:
		return
	if Globals.isPaused:
		return

	#When unpaused, restore velocity
	#elif storedVelocity != Vector2.ZERO:
	#	apply_impulse(linear_velocity)
	#	set_linear_damp(1.5)
	#	storedVelocity = Vector2.ZERO
	
	#if target exists, path to it while out of range.
	if  frameCount % pathUpdateFrames == 0:
		if is_instance_valid(target) and targetInRange:
			$NavigationAgent2D.target_position = position
			return
		if target != null && $NavigationAgent2D.is_navigation_finished():
			$NavigationAgent2D.target_position = target.global_position
		#If path exists already, update it every 30 frames for better performance
		if !$NavigationAgent2D.is_navigation_finished():
			$NavigationAgent2D.target_position = target.global_position
		
		#Stop if target is in range
		
	frameCount += 1
	#direction = self.position.direction_to($NavigationAgent2D.get_next_path_position())
	#velocity = direction * walk_speed
	velocity = position.direction_to($NavigationAgent2D.get_next_path_position()) * walk_speed
	move_and_slide()



#Manual Targeting.
func _on_mouse_detection_mouse_shape_entered(_shape_idx: int) -> void:
	mouseInArea = true
	Globals.mouseInEnemyArea += 1

func _on_mouse_detection_mouse_shape_exited(_shape_idx: int) -> void:
	mouseInArea = false
	Globals.mouseInEnemyArea -= 1

func updateHealthBar():
	return
	var healthBar = $Control/HealthBar
	
	healthBar.max_value = base_health
	healthBar.value = health
	
	#1 at 100, 0 at 0
	var healthBarPercent = healthBar.value / healthBar.max_value
	
	var colorRed = 0
	var colorGreen = 400
	colorGreen = lerp(0, 400, healthBarPercent)
	colorRed = lerp(255, 0, healthBarPercent)
	var fill_stylebox = $Control/HealthBar.get_theme_stylebox("fill")
	fill_stylebox.bg_color = Color(colorRed/255, colorGreen/255, 0)
	
	healthBar.add_theme_stylebox_override("fill", fill_stylebox)


func _on_detect_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("unit"):
		set_physics_process(true)
		set_process(true)
		visible = true
		target = body

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("unit"):
		targetInRange = true
		target = body

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body == target:
		targetInRange = false
