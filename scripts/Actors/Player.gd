extends "Lucjan.gd"

var timer
var wait_timer
#var d = 0
var skillChecks = []
var possibleSkillChecks = ["move_left", "move_right", "move_up", "move_down"]
var skillCheckStep = 0

func _init():
	character_file_path = "res://Data/mikut_data.json"


func use_item(item):
	if item[1] != 0:
		Hp -= int(item[1])
	elif item[2] != 0:
		Hp += int(item[2])
	saveData()

func _ready():
	#hp, max_hp, mele_skills, range_skills, ammo, ammo_texture_path
	load_data()
	$AttackMenu.load_data(Hp, MaxHp, {}, {}, 0, "")

func unlock():
	$PlayerBody.unlock_movement()


func lock():
	$PlayerBody.lock_movement()
	
func get_dmg(attack):
	print("DAMAGED")
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
		queue_free()
	else:
		$AttackMenu.load_data(Hp, MaxHp, {}, {}, 0, "")


func _process(delta):
	if duringSkillCheck:
		if Input.is_action_just_pressed(skillChecks[skillCheckStep], true):
			duringSkillCheck = false
			timer.timeout.emit()
			timer.stop()
			#if skillCheckStep < len(skillChecks) - 1:
				#skillCheckStep += 1


	if waiting and !wait_timer.is_paused():
		#100 / floor(wait_timer.wait_time / delta)
		$AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar.step = $AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar.max_value / (wait_timer.wait_time / delta)
		$AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar.value += $AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar.step
func _on_attack_menu_i_will_attack():
	ready_to_attack_bool = true
	ready_to_attack.emit(Attack, self)
	
func start_attack(attack):
	ready_to_attack_bool = false
	$MeleSkillCheck.visible = true
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = float(attack.wait_time)
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	#asdasd
	for i in range(4):
		var rand = RandomNumberGenerator.new()
		skillChecks.append(possibleSkillChecks[rand.randi_range(0, len(possibleSkillChecks) - 1)])
	$MeleSkillCheck.texture = load("res://Graphics/" + str(skillChecks[skillCheckStep]) +".png")
	print(skillChecks)
	duringSkillCheck = true
	selected_attack = attack
	timer.start()
	
func _on_timer_timeout():
		$MeleSkillCheck.visible = false
		if duringSkillCheck:
			skillCheckFailed = true
			attacking.emit({"dmg": 0})
			print("failed")
			timer.queue_free()
		else:
			if skillCheckStep == len(skillChecks) - 1:
				print("correct")
				attacking.emit(selected_attack)
				timer.queue_free()
				skillChecks.clear()
				skillCheckStep = 0
			else:
				skillCheckStep += 1
				duringSkillCheck = true
				$MeleSkillCheck.texture = load("res://Graphics/" + str(skillChecks[skillCheckStep]) +".png")
				$MeleSkillCheck.visible = true
				var temp_wait_time = timer.wait_time
				timer.queue_free()
				timer = Timer.new()
				timer.one_shot = true
				timer.wait_time = float(temp_wait_time)
				timer.timeout.connect(_on_timer_timeout)
				add_child(timer)
				timer.start()

func _on_attack_done():
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
