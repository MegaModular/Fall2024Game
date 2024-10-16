extends Node2D

var minEnemiesSpawned = 3
var maxEnemiesSpawned = 8

var isElite : bool = false

var spread = 10

var spawnedEnemy

#Change to differnt types once they are made.
@onready var baseMeleeScene = preload("res://EnemyScenes/base_melee_enemy.tscn")
@onready var skeletonArcher = preload("res://EnemyScenes/FinishedEnemies/skeleton_archer.tscn")


@onready var enemiesHolder = $"../../Enemies"

func _ready() -> void:
	randomize()
	var enemy
	spawnedEnemy = get_random_enemy()
	for i in range(randi_range(minEnemiesSpawned, maxEnemiesSpawned)):
		if spawnedEnemy == 0:
			enemy = baseMeleeScene.instantiate()
		else:
			enemy = skeletonArcher.instantiate()
		enemy.position = self.global_position + Vector2(randf_range(-spread, spread), randf_range(-spread,spread))
		if isElite and i == 0:
			enemy.isElite = true
			enemy.set_modulate(Color(0, 0, 1, 1))
		enemiesHolder.add_child(enemy)
		
			
		#enemy.apply_impulse(Vector2(randf_range(0, 200), randf_range(0,200)))
	queue_free()

func get_random_enemy():
	var x = randf_range(0,1)
	var h
	if x < 0.5:
		h = 0
	else:
		h = 1
	return h
