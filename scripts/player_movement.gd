extends CharacterBody2D

#speed of player
var speed = 300.0
#variable blocking player movement
var can_move = true

func get_input():
	#var directionX =  Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#var directionY =  Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var directionX = 0
	var directionY = 0
	
	#setting Y axis in player movement vector if player is not moving in X axis
	if Input.get_action_strength("move_right") - Input.get_action_strength("move_left") == 0 and Input.get_action_strength("move_down") - Input.get_action_strength("move_up") != 0 :
		directionY =  Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	#setting X axis in player movement vector if player is not moving in Y axis
	elif Input.get_action_strength("move_right") - Input.get_action_strength("move_left") != 0 and Input.get_action_strength("move_down") - Input.get_action_strength("move_up") == 0:
		directionX = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	#setting player speed
	if Input.is_action_pressed("run"):
		speed = 380.0
	else:
		speed = 300.0
	#returning player movement vector
	return Vector2(directionX, directionY)

func _physics_process(delta):
	#moving player
	if can_move:
		var directionVector = get_input()
		velocity = directionVector.normalized() * speed
		move_and_slide()

