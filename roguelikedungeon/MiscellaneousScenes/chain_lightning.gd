extends Area2D

var speed = 1000

var targets = []

var target = null

var index = 0
var velocity = Vector2.ZERO

var randDirectionVector = Vector2.ZERO

func _ready():
	#print(targets)
	if !targets.is_empty():
		target = targets[0]
		return
	queue_free()

#Spaghetti Code. Was kind of a fever dream coding it lmfao idk what it does exactly
func _process(delta: float) -> void:
	#Target selection
	targets = Globals.cleanArray(targets)
	if index >= targets.size():
		index = 0
	if target == null && !targets.is_empty():
		target = targets[index]
	if !targets.is_empty() && is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		velocity += dir * speed * delta
		velocity = lerp(velocity, Vector2.ZERO, 0.25)
		global_position += velocity
	index += 1
	if targets.is_empty():
		$CPUParticles2D.emitting = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		get_parent().on_lightning_hit(body)
		if body == target:
			target = null
			velocity = Vector2.ZERO
			targets.erase(body)

func _on_cpu_particles_2d_finished() -> void:
	queue_free()
