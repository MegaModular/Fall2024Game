extends RigidBody2D

@export var isSelected : bool = false
var mouseInArea : bool = false

func _process(_delta):
	selectionLogic()

func selectionLogic():
	if Input.is_action_just_pressed("lmb"):
		if Input.is_action_pressed("shift"):
			if mouseInArea: 
				Select()
			if !mouseInArea:
				pass
		else:
			if mouseInArea:
				Select()
			if !mouseInArea:
				deSelect()

func Select() -> void:
	#print("Selected", self)
	isSelected = true
	$SelectIndicator.visible = true

func deSelect() -> void:
	#print("deSelected", self)
	isSelected = false
	$SelectIndicator.visible = false

func _on_mouse_shape_entered(_shape_idx: int) -> void:
	#print("Mouse Detected", self)
	$MouseHover.visible = true
	mouseInArea = true

func _on_mouse_shape_exited(_shape_idx: int) -> void:
	#print("Mouse No Longer Detected", self)
	$MouseHover.visible = false
	mouseInArea = false
