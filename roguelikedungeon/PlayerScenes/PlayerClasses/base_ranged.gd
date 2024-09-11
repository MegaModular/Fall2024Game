extends "res://PlayerScenes/base_player.gd"

func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.isPaused:
		return
	super(delta)
	if state == "attacking" && potentialTargets.has(attackTarget):
		attack()
		attackMoveLocation = Vector2.ZERO
		return

func attack():
	if ableToAttack:
		ableToAttack = false
		update_stats()
		$AttackCooldownTimer.start()
		shoot()

func shoot():
	print("Shoot, function should be overridden")
	return
