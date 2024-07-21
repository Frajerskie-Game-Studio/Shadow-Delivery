extends CharacterBody2D

var started = false
var enemy_positon
var direction
var speed = 1000.0

func get_direction(en_position):
	var directionX = 0
	var directionY = 0
	
	var random = RandomNumberGenerator.new()
	var rand_x = random.randi_range(1, get_viewport().size.x - 1)
	var rand_y = random.randi_range(1, get_viewport().size.y - 1)
	global_position = Vector2(rand_x, rand_y)
	enemy_positon = en_position
	direction = global_position.direction_to(enemy_positon)
	
	#setting Y axis if player is not moving in X axis
	#if Input.get_action_strength("move_right") - Input.get_action_strength("move_left") == 0 and Input.get_action_strength("move_down") - Input.get_action_strength("move_up") != 0 :
		#directionY = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	##setting X axis if player is not moving in Y axis
	#elif Input.get_action_strength("move_right") - Input.get_action_strength("move_left") != 0 and Input.get_action_strength("move_down") - Input.get_action_strength("move_up") == 0:
		#directionX = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#elif last_vector.x == 0:
		#directionY = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	#else:
		#directionX = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	#setting player speed
	#if Input.is_action_pressed("run"):
		#speed = 380.0
	#else:
		#speed = 300.0
	#last_vector = Vector2(directionX, directionY)
	#return Vector2(directionX, directionY)
	

func _physics_process(delta):
	if started:
		if global_position != enemy_positon:
			velocity = direction.normalized() * speed
			move_and_slide()	
