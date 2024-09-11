extends Node2D


var isPlayerOwned : bool = true
var projectileType = "Arrow" #"Magic"

var direction = Vector2.RIGHT
var speed : float = 1000.0
var velocity

var playerReference


func _ready() -> void:
	if isPlayerOwned:
		playerReference = get_parent().get_parent()
	rotation = direction.angle()

func _process(delta: float) -> void:
	if Globals.isPaused:
		return
	velocity = direction * speed * delta
	position += velocity

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		playerReference._on_contact(body)
		queue_free()
	if body.is_in_group("unit"):
		return
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
