extends "Lucjan.gd"

var timer


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
