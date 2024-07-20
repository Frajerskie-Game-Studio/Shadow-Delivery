extends "Lucjan.gd"

var timer
var wait_timer
var d = 0

func _init():
	character_file_path = "res://Data/mikut_data.json"


func use_item(item):
	if item[1] != 0:
		Hp -= int(item[1])
	elif item[2] != 0:
		Hp += int(item[2])
	saveData()



func unlock():
	$PlayerBody.unlock_movement()


func lock():
	$PlayerBody.lock_movement()


func _process(delta):
	if duringSkillCheck:
		if Input.is_action_pressed("move_left"):
			duringSkillCheck = false
			timer.timeout.emit()
			timer.stop()
	if waiting:
		print(delta)
		#100 / floor(wait_timer.wait_time / delta)
		$AttackMenu/HBoxContainer/RightMenu/ChangeAndTime/WaitTimeBar.value +=  100 / (wait_timer.wait_time / delta)
		d +=  100 / (wait_timer.wait_time / delta)
		print(d)

func _on_attack_menu_i_will_attack():
	ready_to_attack.emit(Attack, self)
	
func start_attack(attack):
	$MeleSkillCheck.visible = true
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 2
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	duringSkillCheck = true
	selected_attack = attack
	timer.start()
	
func _on_timer_timeout():
	$MeleSkillCheck.visible = false
	if duringSkillCheck:
		skillCheckFailed = true
		attacking.emit({"dmg": 0})
		print("failed")
	else:
		print("correct")
		attacking.emit(selected_attack)
	timer.queue_free()

func _on_attack_done():
	$AttackMenu/HBoxContainer/LeftMenu.visible = false
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
	$AttackMenu/HBoxContainer/LeftMenu.visible = true
