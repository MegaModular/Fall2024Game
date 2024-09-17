extends "res://PlayerScenes/PlayerClasses/base_ranged.gd"

var x

const abilities = ["RapidFire", "PowerShot", "Explosive Arrows"]

var selectedAbility

var isArrowExplosive : bool = false

var explosiveEIA = []

func _ready() -> void:
	level = 10
	bonus_attack_speed += 0.5
	heroClass = "ranger"
	super()

func _process(delta: float) -> void:
	super(delta)
	
	if isSelected:
		#Ability Input Handling
		if abilitySelected == abilities[0]:
			if Input.is_action_just_pressed("e") && $AbilityCooldownTimer.is_stopped():
				rapidFire()
				$AbilityCooldownTimer.start()
		if abilitySelected == abilities[1]:
			if Input.is_action_just_pressed("e") && $AbilityCooldownTimer.is_stopped():
				powerShot()
				$AbilityCooldownTimer.start()
		if abilitySelected == abilities[2] && !isArrowExplosive:
			explosiveArrows()
		elif isArrowExplosive && abilitySelected != abilities[2]:
			bonus_attack_speed += 100.0
			isArrowExplosive = false
			update_stats()
	
	if !$AbilityTimer.is_stopped():
		$Control/Control/AbilityDurationBar.value = $AbilityTimer.time_left

func rapidFire():
	print("RapidFire Cast" + str(self))
	var cooldownTime = 15.0
	var abilityDuration = 10.0
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	#Both because this ability takes multiple seconds to expire.
	$AbilityCooldownTimer.set_wait_time(cooldownTime + abilityDuration)
	$Control/Control/AbilityDurationBar.max_value = abilityDuration
	$Control/Control/AbilityDurationBar.visible = true
	$AbilityTimer.set_wait_time(abilityDuration)
	bonus_attack_speed += 0.5 * level
	update_stats()
	$AbilityTimer.start()
	lastAbilityCast = abilities[0]
	lastAbilityLevel = level

func powerShot():
	return

#passive ability
func explosiveArrows():
	#Both because this ability takes multiple seconds to expire.
	$AbilityTimer.set_wait_time(1.0)
	$AbilityTimer.start()
	lastAbilityCast = abilities[2]
	isArrowExplosive = true

func shoot():
	#print("This function was called from the ranger scene.")
	var basicArrow = Globals.projectileReference.instantiate()
	basicArrow.direction = (attackTarget.position - position).normalized()
	basicArrow.projectileType = "Arrow"
	basicArrow.position = position
	$Projectiles.add_child(basicArrow)

#Change Explosive Arrow to do burn damage over time.
func _on_contact(body, arrowPos):
	#print("Hey busta" + str(body))
	if isArrowExplosive:
		$ExplosiveArrowArea.global_position = arrowPos
		for enemy in explosiveEIA:
			enemy.applyDamage(attack_damage * (1 + (0.1*level)), 0)
		return
	body.applyDamage(attack_damage, 0)


func _on_ability_timer_timeout() -> void:
	if lastAbilityCast == abilities[0]:
		bonus_attack_speed -= 0.5 * level
		$Control/Control/AbilityDurationBar.visible = false
		update_stats()
	if lastAbilityCast == abilities[2]:
		bonus_attack_speed -= 100.0
		update_stats()
		lastAbilityLevel = level
	#Whirlwind


func _on_explosive_arrow_area_body_entered(body: Node2D) -> void:
	explosiveEIA = cleanArray(explosiveEIA)
	if body.is_in_group("enemy"):
		explosiveEIA.append(body)


func _on_explosive_arrow_area_body_exited(body: Node2D) -> void:
	explosiveEIA = cleanArray(explosiveEIA)
	if explosiveEIA.has(body):
		explosiveEIA.erase(body)
