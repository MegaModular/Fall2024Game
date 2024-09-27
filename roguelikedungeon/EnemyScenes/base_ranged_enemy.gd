extends "res://EnemyScenes/base_enemy.gd"

var ableToAttack = true

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	if Globals.isPaused:
		if !$AttackTimer.is_paused():
			$AttackTimer.set_paused(true)
	elif $AttackTimer.is_paused():
		$AttackTimer.set_paused(false)
	super(delta)
	if $NavigationAgent2D.is_navigation_finished() && ableToAttack && targetInRange:
		shoot()
		$AttackTimer.start()
		ableToAttack = false
	return

func shoot():
	#print("Override this function")
	print("This should be overriden")

func _on_attack_timer_timeout() -> void:
	ableToAttack = true
