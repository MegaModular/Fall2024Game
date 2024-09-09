extends RigidBody2D

var AIState = "sleeping"

#Game Variables
@export var base_health = 100.0
@export var base_armor = 20.0
@export var base_magic_resist = 20.0
@export var base_dodge_chance = 10.0
@export var base_speed = 200

@onready var playerReference = $"../../Player/Heroes"
@onready var targetParticlesScene = preload("res://Particles/target_particles.tscn")

var health
var armor
var magic_resist
var dodge_chance
var walk_speed

var mouseInArea = false

var direction = Vector2.ZERO
var velocity

func _ready():
	print(playerReference.get_children())
	walk_speed = base_speed
	health = base_health
	armor = base_armor
	magic_resist = base_magic_resist
	dodge_chance = base_dodge_chance

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
	#Target Selection Code
	if Input.is_action_just_pressed("rmb") && mouseInArea:
		for hero in playerReference.get_children():
			hero.tryToTarget(self)
		for hero in playerReference.get_children():
			if hero.attackTarget == self:
				var particles = targetParticlesScene.instantiate()
				add_child(particles)
				return

func _physics_process(delta: float) -> void:
	direction = Vector2(1, 0)
	velocity = direction * walk_speed
	apply_force(velocity)

#Manual Targeting.
func _on_mouse_detection_mouse_shape_entered(shape_idx: int) -> void:
	mouseInArea = true
	Globals.mouseInEnemyArea += 1

func _on_mouse_detection_mouse_shape_exited(shape_idx: int) -> void:
	mouseInArea = false
	Globals.mouseInEnemyArea -= 1

#Debug, remove later, code accessses heros and calls onEnemyKilled(self), and removes self from playerTarget.
func _on_debug_death_timer_timeout() -> void:
	return
	for hero in playerReference.get_children():
		hero.onEnemyKilled(self)
	queue_free()
