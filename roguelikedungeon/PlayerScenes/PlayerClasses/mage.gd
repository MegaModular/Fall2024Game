extends "res://PlayerScenes/PlayerClasses/base_ranged.gd"


const abilities = ["Blizzard", "Living Bomb", "Chain Lightning"]

@onready var blizzardScene = preload("res://MiscellaneousScenes/blizzard_area.tscn")
@onready var chainLightningScene = preload("res://MiscellaneousScenes/chain_lightning.tscn")
@onready var lightningParticlesScene = preload("res://Particles/electric_damage_particles.tscn")

var mouseInRange : bool = false

var burnGuyEIA = []

var burningGuy = null
var tickTime = 0

func _ready() -> void:
	bonus_ability_damage += 50
	heroClass = "mage"
	moveOrder = 3
	super()

func _input(event: InputEvent) -> void:
	if event is not InputEventMouse:
		$VisionRaycast.target_position = get_local_mouse_position()

var burnGuyPos : Vector2

func _process(delta: float) -> void:
	super(delta)
	#Burns guy whos on fire. Checks to see if hes still alive and if not just makes the shit explode anyway.
	if is_instance_valid(burningGuy):
		burnGuyPos = burningGuy.global_position
	if $BurnParticles.emitting == true:
		$BombExplosion.global_position = burnGuyPos
		$BurnParticles.global_position = burnGuyPos
		$BurningGuyExplosionRange.global_position = burnGuyPos
		tickTime += 1
		if !is_instance_valid(burningGuy):
			$LivingBombBurnDuration.stop()
			$BurnParticles.emitting = false
			_on_living_bomb_burn_duration_timeout()
			return
		if tickTime >= 30:
			burningGuy.applyDamage(0.05 * ability_damage, 1)
			tickTime = 0

	
	if isSelected && !Globals.isPaused:
		#Ability Input Handling
		if abilitySelected == abilities[0]:
			if Input.is_action_just_pressed("r") && $AbilityCooldownTimer.is_stopped() && mouseInRange && !$VisionRaycast.is_colliding():
				blizzard()
				$AbilityCooldownTimer.start()
		if abilitySelected == abilities[1]:
			if Input.is_action_just_pressed("r") && $AbilityCooldownTimer.is_stopped():
				livingBomb()
				$AbilityCooldownTimer.start()
		if abilitySelected == abilities[2]:
			if Input.is_action_just_pressed("r") && $AbilityCooldownTimer.is_stopped() && !$VisionRaycast.is_colliding():
					chainLightning()

func blizzard():
	var cooldownTime = 20.0
	lastAbilityCast = abilities[0]
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	$AbilityCooldownTimer.set_wait_time(cooldownTime)
	var bliz = blizzardScene.instantiate()
	update_stats()
	bliz.fireDamage = ((2 * level) + 2 * ability_damage/100) * (1 + (0.005 * ability_damage))
	bliz.duration = 10.0
	bliz.damageType = 1
	bliz.position = get_global_mouse_position()
	$"../../ClassProjectiles".add_child(bliz)

func chainLightning():
	print("Chain Lightning Called")
	var cooldownTime = 20.0
	lastAbilityCast = abilities[0]
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	$AbilityCooldownTimer.set_wait_time(cooldownTime)
	$BurningGuyExplosionRange.global_position = get_global_mouse_position()
	await get_tree().create_timer(0.1).timeout
	var cl = chainLightningScene.instantiate()
	if !burnGuyEIA.is_empty():
		cl.targets = burnGuyEIA
		$AbilityCooldownTimer.start()
		add_child(cl)
		return
	$AbilityCooldownTimer.set_wait_time(1)

func livingBomb():
	var cooldownTime = 10.0
	lastAbilityCast = abilities[0]
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	$AbilityCooldownTimer.set_wait_time(cooldownTime)
	var proj = Globals.projectileReference.instantiate()
	proj.direction = (get_global_mouse_position() - position).normalized()
	proj.projectileType = "LivingBomb"
	proj.position = position
	$Projectiles.add_child(proj)

func shoot():
	#print("This function was called from the ranger scene.")
	var basicMagicAttack = Globals.projectileReference.instantiate()
	basicMagicAttack.direction = (attackTarget.position - position).normalized()
	basicMagicAttack.projectileType = "Magic"
	basicMagicAttack.position = position
	$Projectiles.add_child(basicMagicAttack)

func _on_contact(body, _arrowPos, arrowType):
	#living bomb hit
	if arrowType == "LivingBomb":
		$LivingBombBurnDuration.start()
		$BurnParticles.emitting = true
		burningGuy = body

	
	body.applyDamage(attack_damage + (ability_damage/100), 1)

func on_lightning_hit(body):
	body.applyDamage((25 * level) + (ability_damage), 1)
	body.applyStun(5)
	var lp = lightningParticlesScene.instantiate()
	lp.position = body.position
	$"../../ClassProjectiles".add_child(lp)
	#print(body)


func _on_ability_range_mouse_entered() -> void:
	mouseInRange = true

func _on_ability_range_mouse_exited() -> void:
	mouseInRange = false


func _on_living_bomb_burn_duration_timeout() -> void:
	$BurnParticles.emitting = false
	$BombExplosion.emitting = true
	burningGuy = null
	await get_tree().create_timer(0.2).timeout
	for enemy in burnGuyEIA:
		enemy.applyDamage((50 * level) + (2 * ability_damage), 1)
	



func _on_burning_guy_explosion_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		burnGuyEIA.append(body)

func _on_burning_guy_explosion_range_body_exited(body: Node2D) -> void:
	burnGuyEIA = cleanArray(burnGuyEIA)
	if burnGuyEIA.has(body):
		burnGuyEIA.erase(body)
