extends "res://PlayerScenes/base_player.gd"

func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if state == "attacking" && potentialTargets.has(attackTarget):
		attack()
		return

func attack():
	if ableToAttack:
		ableToAttack = false
		update_stats(false)
		$AttackCooldownTimer.start()
		shoot()

func shoot():
	return
	print("baseShoot, Override this function.")