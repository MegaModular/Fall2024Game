extends "res://EnemyScenes/base_enemy.gd"

var ableToAttack = true

func _ready() -> void:
	super()
	$AttackRange/CollisionShape2D.shape.radius = 500

func _process(delta: float) -> void:
	if Globals.isPaused:
		if !$AttackTimer.is_paused():
			$AttackTimer.set_paused(true)
	elif $AttackTimer.is_paused():
		$AttackTimer.set_paused(false)
	super(delta)
	if $NavigationAgent2D.is_navigation_finished() && ableToAttack && targetInRange:
		attack()
	return

func attack():
	print("Override this function")
	ableToAttack = false
	$AttackTimer.start()

func _on_attack_timer_timeout() -> void:
	ableToAttack = true
