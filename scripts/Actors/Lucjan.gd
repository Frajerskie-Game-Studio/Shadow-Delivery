extends "Character.gd"

@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")

var timer
var wait_timer
#var d = 0
var skillChecks = []
var possibleSkillChecks = ["move_left", "move_right", "move_up", "move_down"]
var skillCheckStep = 0
var possible_target_position
var current_effect_working

func _init():
	character_file_path = "res://Data/lucjan_data.json"
	
func _ready():
	#hp, max_hp, mele_skills, range_skills, ammo, ammo_texture_path
	load_data()
	load_items()
	load_res()
	reload_menu()
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
	else:
		$AttackMenu.visible = false


func reload_menu():
	$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), "", Items)


func get_dmg(attack):
	if wait_timer != null:
		wait_timer.set_paused(true)
	animationState.travel("get_dmg")
	Hp -= attack.dmg
	if Hp < 0:
		Hp = 0
		
	$AttackMenu/HBoxContainer/RightMenu/HealthBar.value = Hp
	
	if wait_timer != null:
		wait_timer.set_paused(false)
	if Hp <= 0:
		KnockedUp = true
		can_be_attacked = false
	else:
		$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), "", Items)
		
	if ready_to_attack_bool:
		reset_attack.emit()
		$AttackMenu/HBoxContainer/LeftMenu/AttackButton.release_focus()
		$AttackMenu/HBoxContainer/LeftMenu/SkillsButton.release_focus()
		$AttackMenu/HBoxContainer/LeftMenu/ItemsButton.release_focus()

func _process(delta):
	if in_battle:
		$PlayerBody/Collision.disabled = false
		$PlayerBody/LevelCollider.disabled = true
		if KnockedUp:
			$AttackMenu.visible = false
			animationState.travel("knocked_down")
		else:
			$AttackMenu.visible = true

		if timer != null:
			if duringSkillCheck:
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
	else:
		$PlayerBody/Collision.disabled = true
		$PlayerBody/LevelCollider.disabled = false

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
			if len(args) == 6:
				ready_to_attack.emit({"dmg": dmg, "wait_time": args[3], "effect": args[5]}, self)
			elif len(args) == 8:
				if args[5] != current_effect_working:
					ready_to_attack.emit({"dmg": dmg, "wait_time": args[3], "effect": args[5], "effect_duration": args[7], "effect_multipler": args[6]}, self)
			else:
				ready_to_attack.emit({"dmg": dmg, "wait_time": args[3]}, self)
				
func start_attack(attack):
	print("ATTACKING")
	ready_to_attack_bool = false
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = float(attack.wait_time)
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	if current_style == "mele":
		if !attack.has("effect"):
			$MeleSkillCheck.visible = true
			skillCheckStep = 0
			for i in range(4):
				var rand = RandomNumberGenerator.new()
				skillChecks.append(possibleSkillChecks[rand.randi_range(0, len(possibleSkillChecks) - 1)])
			$MeleSkillCheck.texture = load("res://Graphics/" + str(skillChecks[skillCheckStep]) +".png")
		elif attack.effect == "stronger":
				selected_attack = attack
				current_effect_working = attack.effect
				effect_multipler = attack.effect_multipler
				effect_counter = attack.effect_duration
				$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), "", Items)
				_on_attack_done()
				return
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
				animationState.travel("range_attack")
				selected_attack = attack
				attacking.emit(selected_attack)
				decrement_ammo()
				$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), "", Items)
				return
			elif attack.effect == "stronger":
				selected_attack = attack
				current_effect_working = attack.effect
				effect_multipler = attack.effect_multipler
				effect_counter = attack.effect_duration
				$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), "", Items)
				_on_attack_done()
				return
				
	duringSkillCheck = true
	selected_attack = attack
	timer.start()
	
func start_using_item():
	can_be_checked = false
	ready_to_attack_bool = false
	var item = get_parent().possible_attack
	load_items()
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
	#print("KONIEC")
	$MeleSkillCheck.visible = false
	if skillCheckFailed:
		#print("FAILED")
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
			#print("CORRECT")
			attacking.emit(selected_attack)
			if current_style == "range":
				decrement_ammo()
				$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), "", Items)
				animationState.travel("range_attack")
			else:
				animationState.travel("mele_attack")
			$RangeSKillCheck.started = false
			$RangeSKillCheck.visible = false
			timer.queue_free()
			skillChecks.clear()
			skillCheckStep = 0
		else:
			#print("Wyszło")
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
		if current_style == "mele":
			animationState.travel("show_mele")
	if current_style == "range":
		animationState.travel("show_range")
		
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
	if current_style == "mele":
		animationState.travel("hide_mele")
	else:
		animationState.travel("hide_range")
		
func revive(heal):
	KnockedUp = false
	animationState.travel(str(current_style) + "_idle")
	
func use_item(item):
	if item.has("effect"):
		if item.effect == "revive":
			KnockedUp = false
	if item.dmg != 0:
		Hp -= item.dmg
	elif item.heal != 0:
		Hp += item.heal
		if Hp > MaxHp:
			Hp = MaxHp
	Items[item.key][3] -= 1
	if Items[item.key][3] <= 0:
		Items.erase(item.key)
	on_mouse_cursor = false
	can_be_checked = false
	save_data()
	save_items()
	load_items()
	load_data()
	animationState.travel("use_item")

func _on_character_body_2d_mouse_entered():
	if can_be_checked:
		on_mouse_cursor = true
		$CheckSprite.visible = true


func _on_character_body_2d_mouse_exited():
	if can_be_checked:
		on_mouse_cursor = false
		$CheckSprite.visible = false
	


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "hide_mele" or anim_name == "hide_range":
		animationState.travel("change_style")
	elif anim_name == "show_mele":
		animationState.travel("mele_idle")
	elif anim_name == "show_range":
		animationState.travel("range_idle")
	elif anim_name == "mele_attack":
		can_be_attacked = true
		animationState.travel("mele_idle")
	elif anim_name == "range_attack":
		can_be_attacked = true
		if Name == "Lucjan":
			animationState.travel("reload")
		else:
			animationState.travel("change_style")
	elif anim_name == "get_dmg":
		if current_style == "mele":
			animationState.travel("mele_idle")
		else:
			if waiting:
				animationState.travel("change_style")
			else:
				animationState.travel("range_idle")
	elif anim_name == "use_item":
		if current_style == "mele":
			if waiting:
				animationState.travel("change_style")
			else:
				animationState.travel("mele_idle")
		else:
			if waiting:
				animationState.travel("change_style")
			else:
				animationState.travel("range_idle")
	elif anim_name == "reload":
		animationState.travel("hide_range")
