extends Camera2D

#Touchables
var camMoveSpeed = 40.0
#border around camera that can be used for the mouse to move the camera
var cursorMovementSize = 100

#Untouchables
var dir = Vector2.ZERO
var camVelocityMultiplier : float = 0.0
var velocity = Vector2.ZERO
var mousePos = Vector2.ZERO
var desiredPos = position

var centerLoc = position

var speedMultiplier = 0 #0-1, for smoothing.
var speedRampUpTime = 0.1

const SCREENSIZE = Vector2(1920, 1080)


#Try implementing this with offset instead of position.
func _physics_process(delta: float) -> void:
	$Control/Label.text = str(position) + str(Vector2(limit_left, limit_bottom)) + str(Vector2(limit_right, limit_top))
	if Globals.isPaused:
		return
	
	if Input.is_action_pressed("space"):
		#velocity = Vector2.ZERO
		desiredPos = calculate_center(true)
	
	if desiredPos.distance_to(position) > 5:
		position = lerp(position, desiredPos, 0.5)
	
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
	
	#Speeds up if moving cam.
	if dir != Vector2.ZERO:
		speedMultiplier += speedRampUpTime
	elif speedMultiplier != 0:
		speedMultiplier -= speedRampUpTime
	#Clamps the multiplier.
	speedMultiplier = clamp(speedMultiplier, 0, 1)
	
	#updates limits based on location of units.
	centerLoc = calculate_center(false)
	limit_left = centerLoc.x - (SCREENSIZE.x)
	limit_right = centerLoc.x + (SCREENSIZE.x)
	limit_top = centerLoc.y - (SCREENSIZE.y)
	limit_bottom = centerLoc.y + (SCREENSIZE.y)
	
	
	
	velocity += dir * camMoveSpeed * delta
	#velocity = lerp(velocity, Vector2.ZERO, 0.1)
	#position += dir * camMoveSpeed * delta * speedMultiplier
	#if !isCameraOnEdge():
	position += velocity;
	desiredPos = position
	#if isCameraOnEdge():
	#	print("Camera is out of bounds")
		#velocity = Vector2.ZERO
	
	#position = clamp(position, Vector2(limit_left/2, limit_top/2), Vector2(limit_right/2, limit_bottom/2))
	position.x = clamp(position.x, limit_left/2, limit_right/2)
	position.y = clamp(position.y, limit_top/2, limit_bottom/2)
	velocity = lerp(velocity, Vector2.ZERO, 0.1)

#returns true if camera is close to border.
func isCameraOnEdge() -> bool:
	if position.x <= limit_left or position.x >= limit_right:
		return true
	if position.y >= limit_bottom or position.y <= limit_top:
		return true
	return false

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
