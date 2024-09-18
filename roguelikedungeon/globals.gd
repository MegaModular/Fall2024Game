extends Node

@onready var damageTextReference = preload("res://Particles/damage_text.tscn")
@onready var projectileReference = preload("res://MiscellaneousScenes/projectile.tscn")

var mouseInEnemyArea : int = 0

var isPaused : bool = false

var skillHUDVisible : bool = false
var invHUDVisible : bool = false

func cleanArray(array):
	var newArr = []
	if array.is_empty():
		return newArr
	for val in array:
		if is_instance_valid(val):
			newArr.append(val)
	return newArr
