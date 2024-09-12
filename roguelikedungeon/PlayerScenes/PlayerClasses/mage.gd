extends "res://PlayerScenes/PlayerClasses/base_ranged.gd"

var x
const abilities = ["Frost Nova", "Fireball", "Chain Lightning"]

func _ready() -> void:
	bonus_ability_damage += 50
	heroClass = "mage"
	super()

func _process(delta: float) -> void:
	super(delta)

func shoot():
	#print("This function was called from the ranger scene.")
	var basicMagicAttack = Globals.projectileReference.instantiate()
	basicMagicAttack.direction = (attackTarget.position - position).normalized()
	basicMagicAttack.projectileType = "Magic"
	basicMagicAttack.position = position
	$Projectiles.add_child(basicMagicAttack)

func _on_contact(body):
	#print("Hey busta" + str(body))
	body.applyDamage(attack_damage + (ability_damage/100), 1)
