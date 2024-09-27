extends "res://EnemyScenes/base_ranged_enemy.gd"

@onready var projectileScene = preload("res://MiscellaneousScenes/projectile.tscn")



func _ready() -> void:
	super()

func shoot():
	var arrow = projectileScene.instantiate()
	arrow.position = position + (target.position - position).normalized() * 20
	arrow.playerReference = self
	arrow.projectileType = "Arrow"
	arrow.isPlayerOwned = false
	arrow.direction = (target.position - position).normalized()
	get_parent().add_child(arrow)

func _on_contact(body):
	body.applyDamage(attack_damage, 0)
