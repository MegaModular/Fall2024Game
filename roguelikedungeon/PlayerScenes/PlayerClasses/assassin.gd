extends "res://PlayerScenes/PlayerClasses/base_melee.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bonus_attack_damage += 100
	super()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
