extends "res://PlayerScenes/PlayerClasses/base_ranged.gd"

var x

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)

func shoot():
	#print("This function was called from the ranger scene.")
	var basicArrow = Globals.projectileReference.instantiate()
	basicArrow.direction = (attackTarget.position - position).normalized()
	basicArrow.projectileType = "Arrow"
	basicArrow.position = position
	$Projectiles.add_child(basicArrow)

func _on_contact(body):
	#print("Hey busta" + str(body))
	body.applyDamage(attack_damage, 0)
