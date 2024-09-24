extends "res://PlayerScenes/PlayerClasses/base_melee.gd"

const abilities = ["Shield Up", "Whirlwind", "Charge"]


#"Shields up":
#Increases armor by 10 * Level, mr by 5 * level and health regen by 20 * level for 5 seconds.
#"Whirlwind":
#AOE around knight. Deal 5 * level  + 50% AD damage, and heal for 50% of damage dealt. 
#Attack 5 times / second for 3 seconds.
#"Charge":
#Triple move speed for 1 second, and deal 50 * level + 100% AD in an AOE around self after move speed is over.

var whirlwindEIA = []
var chargeEIA = []

func _ready() -> void:
	$WhirlwindArea/CollisionShape2D.disabled = true
	$ChargeArea/CollisionShape2D.disabled = true
	level = 10
	
	heroClass = "knight"
	super()

func shieldsUp():
	print("Shields Up Cast" + str(self))
	var cooldownTime = 15.0
	var abilityDuration = 5.0
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	#Both because this ability takes multiple seconds to expire.
	$AbilityCooldownTimer.set_wait_time(cooldownTime + abilityDuration)
	$Control/Control/AbilityDurationBar.max_value = abilityDuration
	$Control/Control/AbilityDurationBar.visible = true
	$AbilityTimer.set_wait_time(abilityDuration)
	bonus_armor += 10 * level
	bonus_magic_resist += 5 * level
	bonus_health_regen += 20 * level
	update_stats()
	$AbilityTimer.start()
	lastAbilityCast = abilities[0]
	lastAbilityLevel = level
	print("bonus armor: " + str(bonus_armor))

func whirlwind():
	var cooldownTime = 10.0
	var abilityDuration = 3.0
	bonus_omnivamp += 30
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
	
	$WhirlwindDamageTimer.set_wait_time(1.0/5.0)
	update_stats()
	$WhirlwindDamageTimer.start()
	$AbilityTimer.start()

func charge():
	var cooldownTime = 20.0
	var abilityDuration = 3.0
	bonus_walk_speed += 500
	lastAbilityCast = abilities[2]
	lastAbilityLevel = level
	print("Charge Cast" + str(self))
	disableAttack = true
	
	$ChargeParticles.emitting = true
	$Control/Control/AbilityDurationBar.max_value = abilityDuration
	$Control/Control/AbilityDurationBar.visible = true
	$ChargeArea/CollisionShape2D.disabled = false
	cooldownTime -= cooldownTime * cooldown_reduction / 100
	$AbilityCooldownTimer.set_wait_time(cooldownTime + abilityDuration)
	$AbilityTimer.set_wait_time(abilityDuration)
	update_stats()
	$AbilityTimer.start()

func applyWhirlwindDamage():
	whirlwindEIA = cleanArray(whirlwindEIA)
	for enemy in whirlwindEIA:
		enemy.applyDamage(attack_damage * 0.5 + 5*level, 0)
		heal((attack_damage * 0.5 + (5 * level) )* omnivamp/100.0)
		update_health_bar()


func applyChargeDamage():
	chargeEIA = cleanArray(chargeEIA)
	for enemy in chargeEIA:
		enemy.applyDamage(50 * lastAbilityLevel + attack_damage, 0)
		enemy.applyStun(4.0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	
	if isSelected:
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
	
	if !$AbilityTimer.is_stopped():
		$Control/Control/AbilityDurationBar.value = $AbilityTimer.time_left
	

#Called when ability ends (for non-instant ones)
func _on_ability_timer_timeout() -> void:
	#Shields Up
	if lastAbilityCast == abilities[0]:
		$Control/Control/AbilityDurationBar.visible = false
		bonus_armor -= 10 * lastAbilityLevel
		bonus_magic_resist -= 5 * lastAbilityLevel
		bonus_health_regen -= 20 * lastAbilityLevel
		update_stats()
	#Whirlwind
	if lastAbilityCast == abilities[1]:
		disableAttack = false
		$Control/Control/AbilityDurationBar.visible = false
		$WhirlwindArea/CollisionShape2D.disabled = true
		$WhirlwindParticles.emitting = false
		bonus_omnivamp -= 30
		update_stats()
	if lastAbilityCast == abilities[2]:
		applyChargeDamage()
		$ChargeParticles.emitting = false
		$ChargeExplosion.emitting = true
		$ChargeArea/CollisionShape2D.disabled = true
		$Control/Control/AbilityDurationBar.visible = false
		disableAttack = false
		bonus_walk_speed -= 500
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
