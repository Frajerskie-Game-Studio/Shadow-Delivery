extends CharacterBody2D

var speed = 300.0
var can_move = true

func get_input():
	#var directionX =  Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#var directionY =  Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var directionX = 0
	var directionY = 0
	
	if Input.get_action_strength("move_right") - Input.get_action_strength("move_left") == 0 and Input.get_action_strength("move_down") - Input.get_action_strength("move_up") != 0 :
		directionY =  Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	elif Input.get_action_strength("move_right") - Input.get_action_strength("move_left") != 0 and Input.get_action_strength("move_down") - Input.get_action_strength("move_up") == 0:
		directionX = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if Input.is_action_pressed("run"):
		speed = 380.0
	else:
		speed = 300.0
		
	return Vector2(directionX, directionY)

func _physics_process(delta):
	if can_move:
		var directionVector = get_input()
		velocity = directionVector.normalized() * speed
		move_and_slide()

