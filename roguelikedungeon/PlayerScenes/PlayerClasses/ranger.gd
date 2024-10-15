extends "res://PlayerScenes/PlayerClasses/base_ranged.gd"

var x

const abilities = ["RapidFire", "PowerShot", "FireArrow"]

@onready var fireAreaReference = preload("res://MiscellaneousScenes/fire_area.tscn")
@onready var powerShotParticleReference = preload("res://Particles/power_shot_hit_particles.tscn")
#Base stats
var rangerBaseAttackDamage = 5
var rangerBonusAttackDamageLevel = 5
var rangerBaseAttackSpeed = 0.5
var rangerBonusAttackSpeedLevel = 0.25

#Ability Modifiers
var rapidFireAttackSpeedLevel = 0.25
var rapidFireBaseAttackSpeed = 1

var fireAreaExplosionDamageLevel = 10
var fireAreaBurnDamage = 0.25

var powerShotDamageRatio = 4.0

var selectedAbility

var explosiveEIA = []

var desiredRotation : float = 0

func _ready() -> void:
	moveOrder = 2  
	base_attack_speed += rangerBaseAttackSpeed
	base_attack_damage += rangerBaseAttackDamage
	heroClass = "ranger"
	super()

func levelUp():
	bonus_attack_speed += rangerBonusAttackSpeedLevel
	bonus_attack_damage += rangerBonusAttackDamageLevel
	level += 1
	update_stats()

func _process(delta: float) -> void:
	if Globals.isPaused:
		if !$AbilityTimer.is_paused():
			$AbilityTimer.set_paused(true)
		if !$AbilityCooldownTimer.is_paused():
			$AbilityCooldownTimer.set_paused(true)
		return
	elif $AbilityTimer.is_paused():
		$AbilityTimer.set_paused(false)
		$AbilityCooldownTimer.set_paused(false)
	
	super(delta)
	$SpriteRotationHelper.rotation = lerp_angle($SpriteRotationHelper.rotation, desiredRotation, 0.2)
	if is_instance_valid(attackTarget):
		desiredRotation = get_angle_to(attackTarget.global_position)
	elif !$NavAgent.is_navigation_finished():
		desiredRotation = get_angle_to($NavAgent.target_position)
	
	

	
	if !$AbilityTimer.is_stopped():
		$Control/Control/AbilityDurationBar.value = $AbilityTimer.time_left

func _input(_event: InputEvent) -> void:
	if isSelected && !Globals.isPaused:
		#Ability Input Handling
		if abilitySelected == abilities[0]:
			if Input.is_action_just_pressed("e") && $AbilityCooldownTimer.is_stopped():
				rapidFire()
				$AbilityCooldownTimer.start()
		if abilitySelected == abilities[1]:
			if Input.is_action_just_pressed("e") && $AbilityCooldownTimer.is_stopped():
				powerShot()
				$AbilityCooldownTimer.start()
		if abilitySelected == abilities[2]:
			if Input.is_action_just_pressed("e") && $AbilityCooldownTimer.is_stopped():
				fireArrow()
				$AbilityCooldownTimer.start()

func rapidFire():
	print("RapidFire Cast" + str(self))
	var cooldownTime = 15.0
	var abilityDuration = 10.0
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	#Both because this ability takes multiple seconds to expire.
	hud.startHudCooldown(2, cooldownTime + abilityDuration)
	$AbilityCooldownTimer.set_wait_time(cooldownTime + abilityDuration)
	$Control/Control/AbilityDurationBar.max_value = abilityDuration
	$Control/Control/AbilityDurationBar.visible = true
	$AbilityTimer.set_wait_time(abilityDuration)
	bonus_attack_speed += rapidFireBaseAttackSpeed + rapidFireAttackSpeedLevel * level
	update_stats()
	$AbilityTimer.start()
	lastAbilityCast = abilities[0]
	lastAbilityLevel = level

#Waits for a second, then shoots the arrow and it has recoil.
func powerShot():
	var cooldownTime = 10.0
	lastAbilityCast = abilities[1]
	var basicArrow = Globals.projectileReference.instantiate()
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	hud.startHudCooldown(2, cooldownTime)
	$AbilityCooldownTimer.set_wait_time(cooldownTime)
	basicArrow.direction = (get_global_mouse_position() - position).normalized()
	basicArrow.projectileType = "PowerShot"
	basicArrow.position = position + (get_global_mouse_position() - position).normalized() * 20
	desiredRotation = get_angle_to(get_global_mouse_position())
	await get_tree().create_timer(0.5).timeout
	$Projectiles.add_child(basicArrow)
	$AnimationPlayer.play("Attack")
	velocity += Vector2(-basicArrow.direction * 500)

func fireArrow():
	var cooldownTime = 15.0
	lastAbilityCast = abilities[2]
	var basicArrow = Globals.projectileReference.instantiate()
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	$AbilityCooldownTimer.set_wait_time(cooldownTime)
	hud.startHudCooldown(2, cooldownTime)
	basicArrow.direction = (get_global_mouse_position() - position).normalized()
	basicArrow.projectileType = "FireArrow"
	basicArrow.position = position + (get_global_mouse_position() - position).normalized() * 20
	$Projectiles.add_child(basicArrow)
	desiredRotation = get_angle_to(get_global_mouse_position())
	$AnimationPlayer.play("Attack")

func shoot():
	#print("This function was called from the ranger scene.")
	var basicArrow = Globals.projectileReference.instantiate()
	basicArrow.direction = (attackTarget.position - position).normalized()
	basicArrow.projectileType = "Arrow"
	basicArrow.position = position + (attackTarget.position - position).normalized() * 20
	$Projectiles.add_child(basicArrow)
	$AnimationPlayer.set_speed_scale(attack_speed/0.5)
	$AnimationPlayer.play("Attack")

#Change Explosive Arrow to do burn damage over time.
func _on_contact(body, arrowPos, arrowType):
	#print("Hey busta" + str(body))
	if arrowType == "FireArrow":
		var fireArea = fireAreaReference.instantiate()
		fireArea.position = arrowPos
		fireArea.duration = 5
		fireArea.fireDamage = (fireAreaBurnDamage * level) * attack_damage
		fireArea.damageType = 0
		$"../../ClassProjectiles".add_child(fireArea)
	if arrowType == "PowerShot":
		body.applyDamage(powerShotDamageRatio * attack_damage + 50 * level, 0)
		var powerShotParticles = powerShotParticleReference.instantiate()
		powerShotParticles.position = arrowPos
		$"../../ClassProjectiles".add_child(powerShotParticles)
		return
	body.applyDamage(attack_damage, 0)

func _on_ability_timer_timeout() -> void:
	#Rapidfire
	if lastAbilityCast == abilities[0]:
		bonus_attack_speed -= rapidFireBaseAttackSpeed + rapidFireAttackSpeedLevel * level
		$Control/Control/AbilityDurationBar.visible = false
		update_stats()
	if lastAbilityCast == abilities[1]:
		return
	#Fire arrow
	if lastAbilityCast == abilities[2]:
		update_stats()
		lastAbilityLevel = level
	#Whirlwind
