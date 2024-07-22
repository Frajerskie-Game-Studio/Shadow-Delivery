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
	#saveData()

func _ready():
	#hp, max_hp, mele_skills, range_skills, ammo, ammo_texture_path
	load_data()
	load_items()
	$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), "", Items)
	if KnockedUp:
		can_be_attacked = false
	#$RangeSKillCheck.get_direction()
	#$RangeSKillCheck.started = true

func unlock():
	$PlayerBody.unlock_movement()


func lock():
	$PlayerBody.lock_movement()
	
func get_dmg(attack):
	if ready_to_attack_bool:
		reset_attack.emit()
		$AttackMenu/HBoxContainer/LeftMenu/AttackButton.release_focus()
	if wait_timer != null:
		wait_timer.set_paused(true)
		
	Hp -= attack.dmg
	$AttackMenu/HBoxContainer/RightMenu/HealthBar.value = Hp
	if wait_timer != null:
		wait_timer.set_paused(false)
	if Hp <= 0:
		KnockedUp = true
	else:
		$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), "", Items)

func reload_menu():
	$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), "", Items)

func _process(delta):
	if KnockedUp:
		$AttackMenu.visible = false
	else:
		$AttackMenu.visible = true
	
	if timer != null:
		if duringSkillCheck:
			print(timer.get_time_left())
			if current_style == "mele":
				if Input.is_action_just_pressed(skillChecks[skillCheckStep]):
					print("Siadło")
					skillCheckFailed = false
					timer.timeout.emit()
			elif current_style == "range":
				skillCheckFailed = true
				if Input.is_action_just_pressed("Shoot"):
					var on_crossair = get_parent().possible_target.on_crossair
					if on_crossair:
						skillCheckFailed = false
					timer.timeout.emit()
				
	if waiting and !wait_timer.is_paused():
		#100 / floor(wait_timer.wait_time / delta)
		$AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar.step = $AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar.max_value / (wait_timer.wait_time / delta)
		$AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar.value += $AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar.step
		
	if can_be_checked:
		if on_mouse_cursor:
			if Input.is_action_just_pressed("mouse_click"):
				item_being_used.emit(self)
				$CheckSprite.visible = false

func _on_attack_menu_i_will_attack(args):
	ready_to_attack_bool = true
	if args == null:
		if current_effect_working != null and current_effect_working == "stronger":
			Attack[current_style].dmg = Attack[current_style].dmg * effect_multipler
			effect_counter -= 1
			if effect_counter <= 0:
				current_effect_working = null
				effect_multipler = null
				effect_counter = 0
		ready_to_attack.emit(Attack[current_style], self)
	else:
		if len(args) == 2:
			if len(args[0]) == 5:
				ready_to_attack.emit({"dmg": args[0][1], "wait_time": 3, "heal": args[0][2], "key": args[1], "effect": args[0][4]}, self)
			else:
				ready_to_attack.emit({"dmg": args[0][1], "wait_time": 3, "heal": args[0][2], "key": args[1]}, self)
		else:
			var dmg = args[1]
			if current_effect_working != null and current_effect_working == "stronger":
				dmg = dmg * effect_multipler
				effect_counter -= 1
				if effect_counter <= 0:
					current_effect_working = null
					effect_multipler = null
					effect_counter = 0
			print(dmg)
			if len(args) == 6:
				ready_to_attack.emit({"dmg": dmg, "wait_time": args[3], "effect": args[5]}, self)
			elif len(args) == 8:
				if args[5] != current_effect_working:
					ready_to_attack.emit({"dmg": dmg, "wait_time": args[3], "effect": args[5], "effect_duration": args[7], "effect_multipler": args[6]}, self)
			else:
				ready_to_attack.emit({"dmg": dmg, "wait_time": args[3]}, self)
	
func start_attack(attack):
	ready_to_attack_bool = false
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = float(attack.wait_time)
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	#asdasd
	if current_style == "mele":
		$MeleSkillCheck.visible = true
		skillCheckStep = 0
		for i in range(4):
			var rand = RandomNumberGenerator.new()
			skillChecks.append(possibleSkillChecks[rand.randi_range(0, len(possibleSkillChecks) - 1)])
		$MeleSkillCheck.texture = load("res://Graphics/" + str(skillChecks[skillCheckStep]) +".png")
	elif current_style == "range":
		if !attack.has("effect"):
			skillCheckStep = -1
			timer.wait_time = float(2)
			$RangeSKillCheck.visible = true
			possible_target_position = get_parent().possible_target.global_position
			$RangeSKillCheck.get_direction(possible_target_position)
			$RangeSKillCheck.started = true
		else:
			if attack.effect == "all":
				selected_attack = attack
				attacking.emit(selected_attack)
				decrement_ammo()
				$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), "", Items)
				return
	duringSkillCheck = true
	selected_attack = attack
	timer.start()

func start_using_item():
	can_be_checked = false
	ready_to_attack_bool = false
	var item = get_parent().possible_attack
	$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), "", Items)
	can_be_attacked = true
	$AttackMenu/HBoxContainer/LeftMenu/SkillsButton.visible = false
	$AttackMenu/HBoxContainer/LeftMenu/ItemsButton.visible = false
	$AttackMenu/HBoxContainer/LeftMenu/AttackButton.visible = false
	$AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/ChangeStyle.visible = false
	$CheckSprite.visible = false
	var timebar = $AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar
	timebar.visible = true
	wait_timer = Timer.new()
	wait_timer.one_shot = true
	wait_timer.wait_time = item.wait_time
	wait_timer.timeout.connect(_on_wait_time_timeout)
	add_child(wait_timer)
	timebar.max_value = 100
	timebar.value = 0
	waiting = true
	wait_timer.start()
	
func _on_timer_timeout():
	print("KONIEC")
	$MeleSkillCheck.visible = false
	if skillCheckFailed:
		print("FAILED")
		skillCheckFailed = true
		duringSkillCheck = false
		attacking.emit({"dmg": 0})
		if current_style == "range":
			decrement_ammo()
			$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), "", Items)
			$RangeSKillCheck.started = false
			$RangeSKillCheck.visible = false
		timer.queue_free()
	else:
		if skillCheckStep == len(skillChecks) - 1 or skillCheckStep == -1:
			duringSkillCheck = false
			print("CORRECT")
			attacking.emit(selected_attack)
			if current_style == "range":
				decrement_ammo()
				$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), "", Items)
			$RangeSKillCheck.started = false
			$RangeSKillCheck.visible = false
			timer.queue_free()
			skillChecks.clear()
			skillCheckStep = 0
		else:
			print("Wyszło")
			timer.queue_free()
			skillCheckStep += 1
			duringSkillCheck = false
			$MeleSkillCheck.texture = load("res://Graphics/" + str(skillChecks[skillCheckStep]) +".png")
			$MeleSkillCheck.visible = true
			var temp_wait_time = timer.wait_time
			timer = Timer.new()
			timer.one_shot = true
			
			timer.timeout.connect(_on_timer_timeout)
			add_child(timer)
			timer.wait_time = float(1)
			duringSkillCheck = true
			timer.start()

func _on_attack_done():
	print("DONE")
	can_be_attacked = true
	$AttackMenu/HBoxContainer/LeftMenu/SkillsButton.visible = false
	$AttackMenu/HBoxContainer/LeftMenu/ItemsButton.visible = false
	$AttackMenu/HBoxContainer/LeftMenu/AttackButton.visible = false
	$AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/ChangeStyle.visible = false
	var timebar = $AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar
	timebar.visible = true
	wait_timer = Timer.new()
	wait_timer.one_shot = true
	wait_timer.wait_time = selected_attack.wait_time
	wait_timer.timeout.connect(_on_wait_time_timeout)
	add_child(wait_timer)
	timebar.max_value = 100
	timebar.value = 0
	waiting = true
	wait_timer.start()
	
func _on_wait_time_timeout():
	$AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar.visible = false
	wait_timer.queue_free()
	waiting = false
	$AttackMenu/HBoxContainer/LeftMenu/SkillsButton.visible = true
	$AttackMenu/HBoxContainer/LeftMenu/ItemsButton.visible = true
	$AttackMenu/HBoxContainer/LeftMenu/AttackButton.visible = true
	$AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/ChangeStyle.visible = true
	if changing_style:
		set_style()
		changing_style = false


func _on_attack_menu_change_style():
	changing_style = true
	$AttackMenu/HBoxContainer/LeftMenu/SkillsButton.visible = false
	$AttackMenu/HBoxContainer/LeftMenu/ItemsButton.visible = false
	$AttackMenu/HBoxContainer/LeftMenu/AttackButton.visible = false
	$AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/ChangeStyle.visible = false
	var timebar = $AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar
	timebar.visible = true
	wait_timer = Timer.new()
	wait_timer.one_shot = true
	wait_timer.wait_time = 2
	wait_timer.timeout.connect(_on_wait_time_timeout)
	add_child(wait_timer)
	timebar.max_value = 100
	timebar.value = 0
	waiting = true
	wait_timer.start()
	


func _on_player_body_mouse_entered():
	if can_be_checked:
		on_mouse_cursor = true
		$CheckSprite.visible = true


func _on_player_body_mouse_exited():
	if can_be_checked:
		on_mouse_cursor = false
		$CheckSprite.visible = false


#func _on_player_body_mouse_shape_entered(shape_idx):
	#print("MOUSE ENTERED")
