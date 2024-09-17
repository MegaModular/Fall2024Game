extends Area2D

#Object that returns the object impacted, the type of the projectile it is,
#and the position where it impacts.
#Flys straight. at speed pixels/s

var isPlayerOwned : bool = true
var projectileType = "Arrow" #"Magic", #"FireArrow", #"PowerShot

var direction = Vector2.RIGHT
var speed : float = 1000.0
var velocity

var playerReference

#Controls different settings for arrow.
func _ready() -> void:
	$PowerShotParticles.emitting = false
	$FireArrowParticles.emitting = false
	if projectileType == "PowerShot":
		speed *= 2.5
		$PowerShotParticles.emitting = true
	elif projectileType == "FireArrow":
		$FireArrowParticles.emitting = true
	if isPlayerOwned:
		playerReference = get_parent().get_parent()
	rotation = direction.angle()

func _process(delta: float) -> void:
	if Globals.isPaused:
		return
	velocity = direction * speed * delta
	position += velocity

func _on_body_entered(body: Node2D) -> void:
	if projectileType == "PowerShot":
		if body.is_in_group("enemy"):
			playerReference._on_contact(body, self.position, projectileType)
			return
		elif body.is_in_group("unit"):
			return
		else:
			queue_free()
	
	if body.is_in_group("enemy"):
		playerReference._on_contact(body, self.position, projectileType)
		queue_free()
	if body.is_in_group("unit"):
		return
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
