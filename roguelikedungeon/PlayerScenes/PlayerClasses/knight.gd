extends "res://PlayerScenes/base_player.gd"
#Knight class. Should run as a finite state-machine, with the variable "state" inherited from child.

var enemiesInHitArea = []
var isAttacking : bool = false

func _ready():
	super()

#Logic to make the player walk and attack instead of staying at range.
func _process(_delta: float) -> void:
	super(_delta)
	if state == "attacking":
		if attackMoveLocation != Vector2.ZERO && attackTarget != null:
			attackMoveLocation = Vector2.ZERO
		if enemiesInHitArea.has(attackTarget):
			attack()
			return
		if $NavAgent.is_navigation_finished() && is_instance_valid(attackTarget):
			path_to(attackTarget.position)

#stop, start attacking. Handles cooldown and whatnot. Animation will be added here.
func attack():
	if ableToAttack:
		path_to(position)
		attackMoveLocation = Vector2.ZERO
		ableToAttack = false
		path_to(position)
		await get_tree().create_timer(0.25).timeout
		performAttack(attackTarget)
		update_stats(false)
		$AttackCooldownTimer.start()

#Check for valid target & send off the attack
func performAttack(obj):
	if is_instance_valid(obj) && enemiesInHitArea.has(obj):
		obj.applyDamage(attack_damage, 0)
	#print("Attack")
	return

#Melee Range detectors.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		#print("Enemy in area")
		enemiesInHitArea = cleanArray(enemiesInHitArea)
		enemiesInHitArea.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if enemiesInHitArea.has(body):
		enemiesInHitArea = cleanArray(enemiesInHitArea)
		enemiesInHitArea.erase(body)
		#print("Left")
