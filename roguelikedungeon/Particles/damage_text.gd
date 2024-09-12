extends Node2D

var damageAmount = 0

var minSpeed = 200
var maxSpeed = 300
var speed

#0 - phys, 1 - magic, 2 - true
var damageType = 0

var direction = Vector2.UP
var velocity = Vector2.ZERO

@onready var fontSettings = "res://Particles/damage_text.tscn::LabelSettings_ide6k"

func _ready():
	randomize()
	direction += Vector2(randf_range(-0.5, 0.5),0)
	direction.normalized()
	speed = randf_range(minSpeed, maxSpeed)
	#orange/brown
	if damageType == 0:
		self.modulate = Color(255.0/255.0,93.0/255.0,0,1)
	#blu/purple
	if damageType == 1:
		self.modulate = Color(125.0/255.0,110.0/255.0,1,1)
	#white by default
	if damageType == 2:
		return

func _process(delta: float) -> void:
	if Globals.isPaused:
		return
	$Control/Label.set_text(str(damageAmount))
	#$Control/Label.label_settings.Font.Color = Color(0,0,0)"modulate"
	direction += Vector2(0, 4* delta)
	direction.normalized()
	velocity = direction * speed * delta
	position += 2 * velocity


func _on_timer_timeout() -> void:
	queue_free()
