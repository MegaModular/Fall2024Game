extends Area2D

#Declare these when instantiated
var fireDamage : float = 0
var duration : float = 5
var damageType : int = 0 
#0-phys, 1-magic, 2-true

var firstDamage : bool = true
var enemiesInArea = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BombExplosion.emitting = true
	$DeathTimer.set_wait_time(duration)
	$DeathTimer.start()


func _on_body_entered(body: Node2D) -> void:
	enemiesInArea = cleanArray(enemiesInArea)
	if body.is_in_group("enemy"):
		enemiesInArea.append(body)

func cleanArray(array):
	var newArr = []
	if array.is_empty():
		return newArr
	for val in array:
		if is_instance_valid(val):
			newArr.append(val)
	return newArr

func _on_body_exited(body: Node2D) -> void:
	enemiesInArea = cleanArray(enemiesInArea)
	if enemiesInArea.has(body):
		enemiesInArea.erase(body)

func _on_tick_timer_timeout() -> void:
	if $DeathTimer.time_left <= 2:
		$Flame.emitting = false
	$TickTimer.set_wait_time(0.5)
	enemiesInArea = cleanArray(enemiesInArea)
	if firstDamage:
		firstDamage = false
		for body in enemiesInArea:
			body.applyDamage(fireDamage * 3, damageType)
		return
	for body in enemiesInArea:
		body.applyDamage(fireDamage, damageType)

func _on_death_timer_timeout() -> void:
	queue_free()
