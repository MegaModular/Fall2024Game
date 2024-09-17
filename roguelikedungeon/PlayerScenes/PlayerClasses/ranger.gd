extends "res://PlayerScenes/PlayerClasses/base_ranged.gd"

var x

const abilities = ["RapidFire", "PowerShot", "FireArrow"]

@onready var fireAreaReference = preload("res://MiscellaneousScenes/fire_area.tscn")

var selectedAbility

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
		if abilitySelected == abilities[2]:
			if Input.is_action_just_pressed("e") && $AbilityCooldownTimer.is_stopped():
				fireArrow()
				$AbilityCooldownTimer.start()

	
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
func fireArrow():
	#Both because this ability takes multiple seconds to expire.
	var cooldownTime = 15.0
	lastAbilityCast = abilities[2]
	var basicArrow = Globals.projectileReference.instantiate()
	$AbilityCooldownTimer.set_wait_time(cooldownTime)
	basicArrow.direction = (get_global_mouse_position() - position).normalized()
	basicArrow.projectileType = "FireArrow"
	basicArrow.position = position
	$Projectiles.add_child(basicArrow)

func shoot():
	#print("This function was called from the ranger scene.")
	var basicArrow = Globals.projectileReference.instantiate()
	basicArrow.direction = (attackTarget.position - position).normalized()
	basicArrow.projectileType = "Arrow"
	basicArrow.position = position
	$Projectiles.add_child(basicArrow)

#Change Explosive Arrow to do burn damage over time.
func _on_contact(body, arrowPos, arrowType):
	#print("Hey busta" + str(body))
	if arrowType == "FireArrow":
		var fireArea = fireAreaReference.instantiate()
		fireArea.position = arrowPos
		fireArea.duration = 5
		fireArea.fireDamage = 0.5 + (0.25 * level) * attack_damage
		fireArea.damageType = 0
		$"../../ClassProjectiles".add_child(fireArea)
	
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
