extends RigidBody2D

var AIState = "sleeping"

@onready var playerReference = $"../../Player/Heroes"
@onready var targetParticlesScene = preload("res://Particles/target_particles.tscn")

@export var base_health = 100.0
@export var base_armor = 20.0
@export var base_magic_resist = 20.0

var health
var armor
var magic_resist

var mouseInArea = false

func _ready():
	print(playerReference.get_children())
	health = base_health
	armor = base_armor
	magic_resist = base_magic_resist

func applyDamage(damage, type): #0 - Physical, 1 - Magic, 2 - True
	if type == 0:
		damage *= 1 - armor/100.0
	if type == 1:
		damage *= 1 - magic_resist/100.0
	if type == 2:
		print("Dealt true damage")
	health -= damage;
	if health <= 0:
		queue_free()

func _process(_delta):
	if Input.is_action_just_pressed("rmb") && mouseInArea:
		for hero in playerReference.get_children():
			hero.tryToTarget(self)
		for hero in playerReference.get_children():
			if hero.attackTarget == self:
				var particles = targetParticlesScene.instantiate()
				add_child(particles)
				return
		

func _on_mouse_detection_mouse_shape_entered(shape_idx: int) -> void:
	mouseInArea = true
	Globals.mouseInEnemyArea += 1

func _on_mouse_detection_mouse_shape_exited(shape_idx: int) -> void:
	mouseInArea = false
	Globals.mouseInEnemyArea -= 1
