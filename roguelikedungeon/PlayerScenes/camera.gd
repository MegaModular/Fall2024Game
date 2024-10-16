extends Camera2D

#Touchables
var camMoveSpeed = 50.0
#border around camera that can be used for the mouse to move the camera
var cursorMovementSize = 100

#Untouchables
var dir = Vector2.ZERO
var camVelocityMultiplier : float = 0.0
var velocity = Vector2.ZERO
var mousePos = Vector2.ZERO
var desiredPos = position

var centerLoc = position

const SCREENSIZE = Vector2(1920, 1080)

func _process(delta: float) -> void:
	
	
	if Globals.isPaused:
		return
	
	if Input.is_action_pressed("space"):
		velocity = Vector2.ZERO
		desiredPos = calculate_center(true)
	
	if desiredPos.distance_to(position) > 0.3:
		position = lerp(position, desiredPos, 0.5)
		return
	
	mousePos = get_local_mouse_position()
	#print(mousePos)
	dir = Vector2.ZERO

	if Input.is_action_pressed("up") or mousePos.y < -SCREENSIZE.y / 2 + cursorMovementSize:
		dir += Vector2(0, -1)
	if Input.is_action_pressed("down") or mousePos.y > SCREENSIZE.y / 2 - cursorMovementSize:
		dir += Vector2(0, 1)
	if Input.is_action_pressed("left")or mousePos.x < -SCREENSIZE.x / 2 + cursorMovementSize:
		dir += Vector2(-1, 0)
	if Input.is_action_pressed("right") or mousePos.x > SCREENSIZE.x / 2 - cursorMovementSize:
		dir += Vector2(1, 0)
	
	centerLoc = calculate_center(false)
	limit_left = centerLoc.x - (SCREENSIZE.x/1.5)
	limit_right = centerLoc.x + (SCREENSIZE.x/1.5)
	limit_top = centerLoc.y - (SCREENSIZE.y/1.5)
	limit_bottom = centerLoc.y + (SCREENSIZE.y/1.5)
	print(limit_left)
	print(limit_right)
	
	#velocity += dir * camMoveSpeed * delta
	#velocity = lerp(velocity, Vector2.ZERO, 0.1)
	if position.x == limit_left || position.x == limit_right:
		velocity.x = 0
	position += dir * camMoveSpeed
	desiredPos += velocity
	
	

#Calculates the center location of all selected players. Returns empty Vector2 if nothing selected.
func calculate_center(forSelected : bool):
	var num = 0.0
	var storedPosition = Vector2.ZERO
	for hero in $"../Heroes".get_children():
		if hero.isSelected:
			storedPosition += hero.position
			num += 1.0
	if num > 0:
		return storedPosition / num 
	if forSelected:
		return position
	for hero in $"../Heroes".get_children():
		storedPosition += hero.position
		num += 1.0
	return storedPosition / num 


func focusOn(a_position):
	desiredPos = a_position
