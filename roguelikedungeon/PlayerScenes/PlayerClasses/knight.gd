extends "res://PlayerScenes/PlayerClasses/base_melee.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	bonus_health += 120
	bonus_armor += 10
	bonus_magic_resist += 10
	bonus_attack_damage += 20


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
