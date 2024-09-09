extends "res://PlayerScenes/base_player.gd"
#Knight class. Should run as a finite state-machine, with the variable "state" inherited from child.

var enemiesInHitArea = []
var isAttacking : bool = false

func _ready():
	super()

func _process(_delta: float) -> void:
	super(_delta)
	if state == "attacking":
		if attackMoveLocation != Vector2.ZERO && attackTarget != null:
			attackMoveLocation = Vector2.ZERO
		if enemiesInHitArea.has(attackTarget):
			attack()
			return
		if $NavAgent.is_navigation_finished():
			path_to(attackTarget.position)

#stop, start attacking.
func attack():
	path_to(position)
	if ableToAttack:
		attackMoveLocation = Vector2.ZERO
		ableToAttack = false
		path_to(position)
		await get_tree().create_timer(0.25).timeout
		print("attackEnemy")
		update_stats(false)
		$AttackCooldownTimer.start()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		print("Enemy in area")
		enemiesInHitArea = cleanArray(enemiesInHitArea)
		enemiesInHitArea.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if enemiesInHitArea.has(body):
		enemiesInHitArea = cleanArray(enemiesInHitArea)
		enemiesInHitArea.erase(body)
		print("Left")
