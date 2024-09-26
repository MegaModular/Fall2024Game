extends Node2D

var minEnemiesSpawned = 3
var maxEnemiesSpawned = 8

var isElite : bool = false

var spread = 50

#Change to differnt types once they are made.
@onready var baseMeleeScene = preload("res://EnemyScenes/base_melee_enemy.tscn")
@onready var baseRangedScene = preload("res://EnemyScenes/base_ranged_enemy.tscn")


@onready var enemiesHolder = $"../../Enemies"

func _ready() -> void:
	randomize()
	var enemy
	if isElite:
		return
	enemy = baseMeleeScene.instantiate()
	#enemy = baseRangedScene.instantiate()
	for i in range(randi_range(minEnemiesSpawned, maxEnemiesSpawned)):
		
		enemy.position = self.global_position + Vector2(randf_range(-spread, spread), randf_range(-spread,spread))
		enemiesHolder.add_child(enemy)
		#enemy.apply_impulse(Vector2(randf_range(0, 200), randf_range(0,200)))
	queue_free()
