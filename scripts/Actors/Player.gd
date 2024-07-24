extends "Lucjan.gd"


#var timer
#var wait_timer
#var d = 0
#var skillChecks = []
#var possibleSkillChecks = ["move_left", "move_right", "move_up", "move_down"]
#var skillCheckStep = 0
#var possible_target_position

func _init():
	character_file_path = "res://Data/mikut_data.json"


#func use_item(item):
	#if item[1] != 0:
		#Hp -= int(item[1])
	#elif item[2] != 0:
		#Hp += int(item[2])
	#save_data()

func _ready():
	#hp, max_hp, mele_skills, range_skills, ammo, ammo_texture_path
	load_data()
	load_items()
	if in_battle:
		$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), "", Items)
		$AttackMenu.visible =true
		if KnockedUp:
			can_be_attacked = false
			animationState.travel("knocked_down")

		elif current_style == "mele":
			animationState.travel("mele_idle")
		elif current_style == "range":
			animationState.travel("range_idle")
	#$RangeSKillCheck.get_direction()
	#$RangeSKillCheck.started = true


func unlock():
	$PlayerBody.unlock_movement()


func lock():
	$PlayerBody.lock_movement()


func reload_menu():
	$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), "", Items)


#func start_attack(attack):
	#ready_to_attack_bool = false
	#timer = Timer.new()
	#timer.one_shot = true
	#timer.wait_time = float(attack.wait_time)
	#timer.timeout.connect(_on_timer_timeout)
	#add_child(timer)
	##asdasd
	#if current_style == "mele":
		#$MeleSkillCheck.visible = true
		#skillCheckStep = 0
		#for i in range(4):
			#var rand = RandomNumberGenerator.new()
			#skillChecks.append(possibleSkillChecks[rand.randi_range(0, len(possibleSkillChecks) - 1)])
		#$MeleSkillCheck.texture = load("res://Graphics/" + str(skillChecks[skillCheckStep]) +".png")
	#elif current_style == "range":
		#if !attack.has("effect"):
			#skillCheckStep = -1
			#timer.wait_time = float(2)
			#$RangeSKillCheck.visible = true
			#possible_target_position = get_parent().possible_target.global_position
			#$RangeSKillCheck.get_direction(possible_target_position)
			#$RangeSKillCheck.started = true
		#else:
			#if attack.effect == "all":
				#animationState.travel("range_attack")
				#selected_attack = attack
				#attacking.emit(selected_attack)
				#decrement_ammo()
				#$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), "", Items)
				#return
	#duringSkillCheck = true
	#selected_attack = attack
	#timer.start()

		
func get_animation_tree():
	return $AnimationTree


#func _on_player_body_mouse_shape_entered(shape_idx):
	#print("MOUSE ENTERED")
