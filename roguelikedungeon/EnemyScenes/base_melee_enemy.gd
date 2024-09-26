extends "res://EnemyScenes/base_enemy.gd"

var ableToAttack : bool = true

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
		attack()

func attack():
	ableToAttack = false
	target.applyDamage(attack_damage, 0)
	$AttackTimer.start()

func _on_timer_timeout() -> void:
	ableToAttack = true
