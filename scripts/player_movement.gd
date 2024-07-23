extends CharacterBody2D

#speed of player
var speed = 300.0
@onready var animationTree = get_parent().get_animation_tree()
@onready var animationState = animationTree.get("parameters/playback")
#variable allowing player to move
var can_move = true
var last_vector:Vector2

func get_input():
	#var directionX =  Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#var directionY =  Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var directionX = 0
	var directionY = 0
	
	#setting Y axis if player is not moving in X axis
	if Input.get_action_strength("move_right") - Input.get_action_strength("move_left") == 0 and Input.get_action_strength("move_down") - Input.get_action_strength("move_up") != 0 :
		directionY = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	#setting X axis if player is not moving in Y axis
	elif Input.get_action_strength("move_right") - Input.get_action_strength("move_left") != 0 and Input.get_action_strength("move_down") - Input.get_action_strength("move_up") == 0:
		directionX = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	elif last_vector.x == 0:
		directionY = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	else:
		directionX = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	#setting player speed
	if Input.is_action_pressed("run"):
		speed = 380.0
	else:
		speed = 300.0
	var current_vector = Vector2(directionX, directionY)
	if current_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", current_vector + last_vector)
		animationTree.set("parameters/Move/blend_position", current_vector + last_vector)
		animationState.travel("Move")
	else:
		animationState.travel("Idle")
	last_vector = Vector2(directionX, directionY)
	return Vector2(directionX, directionY)
	
func unlock_movement():
	can_move = true
	
func lock_movement():
	can_move = false

func _physics_process(delta):
	#moving player (if he can)
	if can_move:
		var directionVector = get_input()
		velocity = directionVector.normalized() * speed
		move_and_slide()

