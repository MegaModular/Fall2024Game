extends Node2D

var damageAmount = 0

var minSpeed = 200
var maxSpeed = 300
var speed

#0 - phys, 1 - magic, 2 - true
var damageType = 0

var direction = Vector2.UP
var velocity = Vector2.ZERO

func _ready():
	randomize()
	direction += Vector2(randf_range(-0.5, 0.5),0)
	direction.normalized()
	speed = randf_range(minSpeed, maxSpeed)
	#orange/brown
	if damageType == 0:
		self.modulate = Color(218,93,0,255)
	#blu/purple
	if damageType == 1:
		self.modulate = Color(125,110,255,255)
	#white by default
	if damageType == 2:
		return

func _process(delta: float) -> void:
	$Control/Label.set_text(str(damageAmount))
	#$Control/Label.label_settings.Font.Color = Color(0,0,0)"modulate"
	direction += Vector2(0, 4* delta)
	direction.normalized()
	velocity = direction * speed * delta
	position += 2 * velocity


func _on_timer_timeout() -> void:
	queue_free()
