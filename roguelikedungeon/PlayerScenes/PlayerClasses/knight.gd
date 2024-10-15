extends "res://PlayerScenes/PlayerClasses/base_melee.gd"

const abilities = ["Shield Up", "Whirlwind", "Charge"]

#Base
var knightBonusHealth = 100.0
var knightBonusArmor = 10.0
var knightBonusMR = 10.0
var knightBonusHealthRegen = 10.0

#Increase Per Level
var knightHealthLevel = 25.0
var knightArmorLevel = 2
var knightMRLevel = 2

#Ability Modifiers:
#per level
var shieldsUpArmor = 10.0 
var shieldsUpMR = 5.0
var shieldsUpRegen = 20

#Whirlwind hits 5 times / sec.
var whirlwindOmnivamp = 20.0
var whirlwindDamageMultiplier = 0.3
var whirlwindBaseDamage = 3

var chargeMoveSpeed = 200.0
var chargeDamagePerLevel = 25.0

#"Shields up":
#Increases armor by 10 * Level, mr by 5 * level and health regen by 20 * level for 5 seconds.
#"Whirlwind":
#AOE around knight. Deal 5 * level  + 50% AD damage, and heal for 50% of damage dealt. 
#Attack 5 times / second for 3 seconds.
#"Charge":
#Triple move speed for 1 second, and deal 50 * level + 100% AD in an AOE around self after move speed is over.


var whirlwindEIA = []
var chargeEIA = []

var desiredRotation : float = 0.0

func _ready() -> void:
	$WhirlwindArea/CollisionShape2D.disabled = true
	$ChargeArea/CollisionShape2D.disabled = true
	moveOrder = 0
	heroClass = "knight"
	base_health += knightBonusHealth
	base_health_regen += knightBonusHealthRegen
	base_armor += knightBonusArmor
	base_magic_resist += knightBonusMR
	super()

#Call this once every level up.
func levelUp():
	bonus_health += knightHealthLevel
	bonus_armor += knightArmorLevel
	bonus_magic_resist += knightMRLevel
	level += 1
	update_stats()


func shieldsUp():
	print("Shields Up Cast" + str(self))
	var cooldownTime = 10.0
	var abilityDuration = 8.0
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	#Both because this ability takes multiple seconds to expire.
	$AbilityCooldownTimer.set_wait_time(cooldownTime + abilityDuration)
	$Control/Control/AbilityDurationBar.max_value = abilityDuration
	$Control/Control/AbilityDurationBar.visible = true
	$AbilityTimer.set_wait_time(abilityDuration)
	bonus_armor += shieldsUpArmor * level
	bonus_magic_resist += shieldsUpMR * level
	bonus_health_regen += shieldsUpRegen * level
	update_stats()
	$AbilityTimer.start()
	hud.startHudCooldown(0, cooldownTime + abilityDuration)
	lastAbilityCast = abilities[0]
	lastAbilityLevel = level

func whirlwind():
	var cooldownTime = 10.0
	var abilityDuration = 3.0
	bonus_omnivamp += whirlwindOmnivamp
	lastAbilityCast = abilities[1]
	lastAbilityLevel = level
	print("Whirlwind Cast" + str(self))
	disableAttack = true
	
	$WhirlwindParticles.emitting = true
	$WhirlwindArea/CollisionShape2D.disabled = false
	cooldownTime -= cooldownTime * cooldown_reduction / 100
	$AbilityCooldownTimer.set_wait_time(cooldownTime + abilityDuration)
	$Control/Control/AbilityDurationBar.max_value = abilityDuration
	$Control/Control/AbilityDurationBar.visible = true
	$AbilityTimer.set_wait_time(abilityDuration)
	hud.startHudCooldown(0, cooldownTime + abilityDuration)
	
	$WhirlwindDamageTimer.set_wait_time(1.0/5.0)
	update_stats()
	$WhirlwindDamageTimer.start()
	$AbilityTimer.start()

func charge():
	var cooldownTime = 10.0
	var abilityDuration = 2.0
	bonus_walk_speed += chargeMoveSpeed
	lastAbilityCast = abilities[2]
	lastAbilityLevel = level
	print("Charge Cast" + str(self))
	disableAttack = true
	
	$ChargeParticles.emitting = true
	$Control/Control/AbilityDurationBar.max_value = abilityDuration
	$Control/Control/AbilityDurationBar.visible = true
	$ChargeArea/CollisionShape2D.disabled = false
	cooldownTime -= cooldownTime * cooldown_reduction / 100
	hud.startHudCooldown(0, cooldownTime + abilityDuration)
	$AbilityCooldownTimer.set_wait_time(cooldownTime + abilityDuration)
	$AbilityTimer.set_wait_time(abilityDuration)
	update_stats()
	$AbilityTimer.start()

func applyWhirlwindDamage():
	whirlwindEIA = cleanArray(whirlwindEIA)
	for enemy in whirlwindEIA:
		enemy.applyDamage(attack_damage * whirlwindDamageMultiplier + (whirlwindBaseDamage*level), 0)
		heal((attack_damage * whirlwindDamageMultiplier + (whirlwindBaseDamage * level) )* omnivamp/100.0)
		update_health_bar()

#Overriden method from base_melee class
func performAttack(target):
	$AnimationPlayer.play("Attack")
	$AnimationPlayer.set_speed_scale(attack_speed/0.5)
	super(target)

func applyChargeDamage():
	chargeEIA = cleanArray(chargeEIA)
	for enemy in chargeEIA:
		enemy.applyDamage(chargeDamagePerLevel * lastAbilityLevel + attack_damage, 0)
		enemy.applyStun(4.0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.isPaused:
		$AnimationPlayer.pause()
		if !$AbilityTimer.is_paused():
			$AbilityTimer.set_paused(true)
		if !$AbilityCooldownTimer.is_paused():
			$AbilityCooldownTimer.set_paused(true)
		return
	elif $AbilityTimer.is_paused():
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.play()
		$AbilityTimer.set_paused(false)
		$AbilityCooldownTimer.set_paused(false)
	super(delta)
	
	if $AbilityTimer.time_left != 0 && lastAbilityCast == abilities[1]:
		$SpriteRotationHelper.rotation -= 6*PI*delta
	else:
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
			if Input.is_action_just_pressed("q") && $AbilityCooldownTimer.is_stopped():
				shieldsUp()
				$AbilityCooldownTimer.start()
		if abilitySelected == abilities[1]:
			if Input.is_action_just_pressed("q") && $AbilityCooldownTimer.is_stopped():
				whirlwind()
				$AbilityCooldownTimer.start()
		if abilitySelected == abilities[2]:
			if Input.is_action_just_pressed("q") && $AbilityCooldownTimer.is_stopped():
				charge()
				$AbilityCooldownTimer.start()

#Called when ability ends (for non-instant ones)
func _on_ability_timer_timeout() -> void:
	#Shields Up
	if lastAbilityCast == abilities[0]:
		$Control/Control/AbilityDurationBar.visible = false
		bonus_armor -= shieldsUpArmor * lastAbilityLevel
		bonus_magic_resist -= shieldsUpMR * lastAbilityLevel
		bonus_health_regen -= shieldsUpRegen * lastAbilityLevel
		update_stats()
	#Whirlwind
	if lastAbilityCast == abilities[1]:
		disableAttack = false
		$Control/Control/AbilityDurationBar.visible = false
		$WhirlwindArea/CollisionShape2D.disabled = true
		$WhirlwindParticles.emitting = false
		bonus_omnivamp -= whirlwindOmnivamp
		update_stats()
	if lastAbilityCast == abilities[2]:
		applyChargeDamage()
		$ChargeParticles.emitting = false
		$ChargeExplosion.emitting = true
		$ChargeArea/CollisionShape2D.disabled = true
		$Control/Control/AbilityDurationBar.visible = false
		disableAttack = false
		bonus_walk_speed -= chargeMoveSpeed
		update_stats()

func _on_whirlwind_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		whirlwindEIA = cleanArray(whirlwindEIA)
		whirlwindEIA.append(body)


func _on_whirlwind_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		whirlwindEIA = cleanArray(whirlwindEIA)
		whirlwindEIA.erase(body)


func _on_whirlwind_damage_timer_timeout() -> void:
	applyWhirlwindDamage()
	if !$AbilityTimer.is_stopped():
		$WhirlwindDamageTimer.start()


func _on_charge_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		chargeEIA = cleanArray(chargeEIA)
		chargeEIA.append(body)

func _on_charge_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		chargeEIA = cleanArray(chargeEIA)
		chargeEIA.erase(body)
