extends Area2D

var speed = 200

var targets = []

var target = null

var impulseTicks = 0
var index = 0
var velocity = Vector2.ZERO

var randDirectionVector = Vector2.ZERO

func _ready():
	if targets != null:
		target = targets[0]
		return
	queue_free()

#ChainLightnign needs to move independent of player and reference it.
func _process(delta: float) -> void:
	#Target selection
	if target == null:
		target = targets[index]
	if targets != null:
		targets = Globals.cleanArray(targets)
		
		var dir = (target.position - position).normalized()
		#if impulseTicks <= 20:
			#velocity += randDirectionVector * 1000 * delta
		velocity += dir * speed * delta
		velocity = lerp(velocity, Vector2.ZERO, 0.25)
		position += velocity
		#pick random target.
		index += 1
		impulseTicks += 1
		if index >= targets.size():
			index = 0
	else:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		get_parent().on_lightning_hit(body)
		impulseTicks = 0
		randDirectionVector = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		if body == target:
			target = null
		if targets.has(body):
			targets.erase(body)
