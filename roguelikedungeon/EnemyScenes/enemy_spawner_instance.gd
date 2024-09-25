extends Node2D

var minEnemiesSpawned = 1
var maxEnemiesSpawned = 5

var isElite : bool = false

var spread = 50

#Change to differnt types once they are made.
@onready var baseEnemyScene = preload("res://EnemyScenes/base_enemy.tscn")

@onready var enemiesHolder = $"../../Enemies"

func _ready() -> void:
	if isElite:
		return
	for i in range(randi_range(minEnemiesSpawned, maxEnemiesSpawned)):
		var enemy = baseEnemyScene.instantiate()
		enemy.position = self.global_position + Vector2(randf_range(-spread, spread), randf_range(-spread,spread))
		enemiesHolder.add_child(enemy)
		#enemy.apply_impulse(Vector2(randf_range(0, 200), randf_range(0,200)))
	queue_free()
