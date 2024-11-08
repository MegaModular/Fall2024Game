extends "res://PlayerScenes/PlayerClasses/base_melee.gd"

#Touchables 
var bombHeight = 500

const abilities = ["Bomb", "Ninja Maneuvers", "Mega Kick"]
# Called when the node enters the scene tree for the first time.
var assassinBaseWalkSpeed = 50.0
var assassinBaseAD = 10
var assassinBaseOmni = 20
var assassinBonusADLevel = 3

var manueversOmni = 30
var manueversDodgeLevel = 0.1
var manueversADLevel = 10
var manueverAS = 0.5

var bombDamageLevel = 20

var kickADRatio = 5

var mouseInRange : bool = false

var NMbonusAD

var bombInAir : bool = false

var bombDesired = Vector2.ZERO

var bombEIA = []

var desiredRotation : float = 0

@onready var bombReference = $"../../ClassProjectiles/Bomb"

func _ready() -> void:
	heroClass = "assassin"
	moveOrder = 1
	base_walk_speed += assassinBaseWalkSpeed
	base_attack_damage += assassinBaseAD
	base_omnivamp += assassinBaseOmni
	$BombExplosionRange/CollisionShape2D.disabled = true
	super()

func levelUp():
	bonus_attack_damage += assassinBonusADLevel
	level += 1
	update_stats()

func _input(event: InputEvent) -> void:
	if event is not InputEventMouse:
		$BombRaycast.target_position = get_local_mouse_position()
	if isSelected && !Globals.isPaused:
		#Ability Input Handling
		if abilitySelected == abilities[0]:
			if Input.is_action_just_pressed("w") && $AbilityCooldownTimer.is_stopped() && ableToBomb():
				bomb()
				$AbilityCooldownTimer.start()
		if abilitySelected == abilities[1]:
			if Input.is_action_just_pressed("w") && $AbilityCooldownTimer.is_stopped():
				ninjaManeuvers()
				$AbilityCooldownTimer.start()
		if abilitySelected == abilities[2]:
			if Input.is_action_just_pressed("w") && $AbilityCooldownTimer.is_stopped() && enemiesInHitArea.has(attackTarget):
				megaKick()
				$AbilityCooldownTimer.start()

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
		$AnimationPlayer.play()
		$AbilityTimer.set_paused(false)
		$AbilityCooldownTimer.set_paused(false)
	
	super(delta)
	$SpriteRotationHelper.rotation = lerp_angle($SpriteRotationHelper.rotation, desiredRotation, 0.2)
	if is_instance_valid(attackTarget):
		desiredRotation = get_angle_to(attackTarget.global_position)
	elif !$NavAgent.is_navigation_finished():
		desiredRotation = get_angle_to($NavAgent.target_position)
	
	if bombInAir:
		bombReference.position = lerp(bombReference.position, bombDesired, 5 * delta)
	
	if !$AbilityTimer.is_stopped():
		$Control/Control/AbilityDurationBar.value = $AbilityTimer.time_left

func performAttack(target):
	$AnimationPlayer.play("Attack")
	$AnimationPlayer.set_speed_scale(attack_speed/0.5)
	super(target)

func ableToBomb() -> bool:
	if !mouseInRange:
		return false
	if $BombRaycast.is_colliding():
		return false
	return true

func bomb():
	print("bomb Thrown " + str(self))
	var cooldownTime = 20.0
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	hud.startHudCooldown(1, cooldownTime)
	#Both because this ability takes multiple seconds to expire.
	$AbilityCooldownTimer.set_wait_time(cooldownTime)
	lastAbilityCast = abilities[0]
	throwBomb()

func throwBomb():
	bombDesired = get_global_mouse_position()
	bombEIA.clear()
	bombInAir = true
	$BombFuse.start()
	bombReference.position = position
	bombReference.visible = true

func _on_bomb_fuse_timeout() -> void:
	print("Fuse timeout")
	bombInAir = false
	$BombExplosion.global_position = bombReference.global_position
	$BombExplosion.emitting = true
	bombReference.visible = false
	$BombExplosionRange/CollisionShape2D.disabled = false
	$BombExplosionRange.global_position = bombReference.position
	await get_tree().create_timer(0.1).timeout
	bombEIA = cleanArray(bombEIA)
	for enemy in bombEIA:
		var damage = (bombDamageLevel * level) + attack_damage
		enemy.applyDamage(damage, 0)
	$BombExplosionRange/CollisionShape2D.disabled = true
	$BombExplosionRange.global_position = self.position

func ninjaManeuvers():
	print(attack_damage)
	print("Ninja Maneuvers Cast " + str(self))
	var cooldownTime = 12.0
	var abilityDuration = 8.0
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	#Both because this ability takes multiple seconds to expire.
	hud.startHudCooldown(1, cooldownTime + abilityDuration)
	$AbilityCooldownTimer.set_wait_time(cooldownTime + abilityDuration)
	$Control/Control/AbilityDurationBar.max_value = abilityDuration
	$Control/Control/AbilityDurationBar.visible = true
	$AbilityTimer.set_wait_time(abilityDuration)
	bonus_attack_speed += manueverAS
	bonus_dodge_chance += manueversDodgeLevel * level
	bonus_omnivamp += manueversOmni
	NMbonusAD = (manueversADLevel * level)
	bonus_attack_damage += NMbonusAD
	update_stats()
	$AbilityTimer.start()
	lastAbilityCast = abilities[1]
	lastAbilityLevel = level

func megaKick():
	print("Mega kick " + str(self))
	var cooldownTime = 10.0
	cooldownTime -= cooldownTime * cooldown_reduction/ 100
	$AbilityCooldownTimer.set_wait_time(cooldownTime)
	hud.startHudCooldown(1, cooldownTime)
	#var impulse = position.direction_to(attackTarget.position)
	#attackTarget.velocity += (impulse * 200)
	attackTarget.applyDamage(kickADRatio * attack_damage, 2)
	lastAbilityCast = abilities[2]

func _on_bomb_range_mouse_entered() -> void:
	mouseInRange = true

func _on_bomb_range_mouse_exited() -> void:
	mouseInRange = false

func _on_bomb_explosion_range_body_entered(body: Node2D) -> void:
	bombEIA = cleanArray(bombEIA)
	if body.is_in_group("enemy"):
		bombEIA.append(body)

func _on_ability_timer_timeout() -> void:
	if lastAbilityCast == abilities[1]:
		$Control/Control/AbilityDurationBar.visible = false
		bonus_dodge_chance -= manueversDodgeLevel * lastAbilityLevel
		bonus_omnivamp -= manueversOmni
		bonus_attack_speed -= manueverAS
		bonus_attack_damage -= NMbonusAD
		update_stats()
