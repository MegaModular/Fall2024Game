extends Node

@onready var damageTextReference = preload("res://Particles/damage_text.tscn")
@onready var projectileReference = preload("res://MiscellaneousScenes/projectile.tscn")

var mouseInEnemyArea : int = 0

var isPaused : bool = false
