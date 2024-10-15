extends "res://PlayerScenes/PlayerClasses/base_ranged.gd"

const abilities = ["Blizzard", "Living Bomb", "Chain Lightning"]
#Base stats
var mageBonusAbilityDamage = 25
var mageBonusAbilityDamageLevel = 25
#AbiltiyModifiers
#this damage * AP/100 , also total damage multiplied by this too.
var blizzardBaseAbilityRatio = 4.0
#damage * level, base
var blizzardBaseDamage = 4.0

var livingBombApRatio = 0.5
var livingBombDamagePerLevel = 20
var burnAPRatio = 0.05

var chainLightningBaseDamage = 15
var chainLightningDamageLevel = 10
var chainLightningAPRatio = 0.25



@onready var blizzardScene = preload("res://MiscellaneousScenes/blizzard_area.tscn")
@onready var chainLightningScene = preload("res://MiscellaneousScenes/chain_lightning.tscn")
@onready var lightningParticlesScene = preload("res://Particles/electric_damage_particles.tscn")

var mouseInRange : bool = false

var burnGuyEIA = []

var burningGuy = null
var tickTime = 0

var desiredRotation : float = 0

func _ready() -> void:
	base_ability_damage += mageBonusAbilityDamage
	heroClass = "mage"
	moveOrder = 3
	super()

func levelUp():
	bonus_ability_damage += mageBonusAbilityDamageLevel
	level += 1
	update_stats()

func _input(event: InputEvent) -> void:
	if event is not InputEventMouse:
		$VisionRaycast.target_position = get_local_mouse_position()
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

var burnGuyPos : Vector2

func _process(delta: float) -> void:
	
	if Globals.isPaused:
		if !$LivingBombBurnDuration.is_paused():
			$LivingBombBurnDuration.set_paused(true)
		if !$AbilityCooldownTimer.is_paused():
			$AbilityCooldownTimer.set_paused(true)
		return
	elif $LivingBombBurnDuration.is_paused():
		$LivingBombBurnDuration.set_paused(false)
		$AbilityCooldownTimer.set_paused(false)
	super(delta)
	
	$SpriteRotationHelper.rotation = lerp_angle($SpriteRotationHelper.rotation, desiredRotation, 0.2)
	if is_instance_valid(attackTarget):
		desiredRotation = get_angle_to(attackTarget.global_position)
	elif !$NavAgent.is_navigation_finished():
		desiredRotation = get_angle_to($NavAgent.target_position)
	
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
			burningGuy.applyDamage(burnAPRatio * ability_damage, 1)
			tickTime = 0

func blizzard():
	var cooldownTime = 20.0
	lastAbilityCast = abilities[0]
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	$AbilityCooldownTimer.set_wait_time(cooldownTime)
	hud.startHudCooldown(3, cooldownTime)
	var bliz = blizzardScene.instantiate()
	update_stats()
	bliz.fireDamage = ((blizzardBaseDamage * level) + blizzardBaseAbilityRatio * ability_damage/100) * (1 + (blizzardBaseAbilityRatio/1000 * ability_damage))
	bliz.duration = 10.0
	bliz.damageType = 1
	bliz.position = get_global_mouse_position()
	desiredRotation = get_angle_to(get_global_mouse_position())
	$AnimationPlayer.play("Attack")
	await get_tree().create_timer(0.4 * (1/(attack_speed/0.5))).timeout
	$"../../ClassProjectiles".add_child(bliz)

func chainLightning():
	print("Chain Lightning Called")
	var cooldownTime = 10.0
	lastAbilityCast = abilities[0]
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	$AbilityCooldownTimer.set_wait_time(cooldownTime)
	hud.startHudCooldown(3, cooldownTime)
	$BurningGuyExplosionRange.global_position = get_global_mouse_position()
	await get_tree().create_timer(0.1).timeout
	var cl = chainLightningScene.instantiate()
	if !burnGuyEIA.is_empty():
		cl.targets = burnGuyEIA
		$AbilityCooldownTimer.start()
		add_child(cl)
		desiredRotation = get_angle_to(get_global_mouse_position())
		$AnimationPlayer.play("Attack")
		return
	$AbilityCooldownTimer.set_wait_time(0.2)

func livingBomb():
	var cooldownTime = 10.0
	lastAbilityCast = abilities[0]
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	$AbilityCooldownTimer.set_wait_time(cooldownTime)
	hud.startHudCooldown(3, cooldownTime)
	desiredRotation = get_angle_to(get_global_mouse_position())
	$AnimationPlayer.play("Attack")
	var proj = Globals.projectileReference.instantiate()
	proj.direction = (get_global_mouse_position() - position).normalized()
	proj.projectileType = "LivingBomb"
	proj.position = position + (get_global_mouse_position() - position).normalized() * 20
	await get_tree().create_timer(0.4 * (1/(attack_speed/0.5))).timeout
	$Projectiles.add_child(proj)

func shoot():
	#print("This function was called from the ranger scene.")
	var basicMagicAttack = Globals.projectileReference.instantiate()
	basicMagicAttack.direction = (attackTarget.position - position).normalized()
	basicMagicAttack.projectileType = "Magic"
	basicMagicAttack.position = position + (attackTarget.position - position).normalized() * 20
	$AnimationPlayer.set_speed_scale(attack_speed/0.5)
	$AnimationPlayer.play("Attack")
	await get_tree().create_timer(0.4 * (1/(attack_speed/0.5))).timeout
	$Projectiles.add_child(basicMagicAttack)

func _on_contact(body, _arrowPos, arrowType):
	#living bomb hit
	if arrowType == "LivingBomb":
		$LivingBombBurnDuration.start()
		$BurnParticles.emitting = true
		burningGuy = body

	
	body.applyDamage(attack_damage * (1 + ability_damage/100), 1)

func on_lightning_hit(body):
	body.applyDamage((chainLightningBaseDamage + (chainLightningDamageLevel * level)) + (chainLightningAPRatio * ability_damage), 1)
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
		enemy.applyDamage(((livingBombDamagePerLevel * level) + (livingBombApRatio * ability_damage)) * (1 + ability_damage/1000), 1)
	



func _on_burning_guy_explosion_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		burnGuyEIA.append(body)

func _on_burning_guy_explosion_range_body_exited(body: Node2D) -> void:
	burnGuyEIA = cleanArray(burnGuyEIA)
	if burnGuyEIA.has(body):
		burnGuyEIA.erase(body)
