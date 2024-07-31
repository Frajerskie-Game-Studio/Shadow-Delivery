extends "Character.gd"

@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")

var timer
var wait_timer
var skillChecks = []
var possibleSkillChecks = ["move_left", "move_right", "move_up", "move_down"]
var skillCheckStep = 0
var possible_target_position
var current_effect_working
var in_tutorial = false
var ammo_path

signal tutorial_change_signal

func _init():
	character_file_path = "user://Data/lucjan_data.json"
	ammo_path = "res://Graphics/Items/flintlock_ammo_sprite.png"
	
func _ready():
	#hp, max_hp, melee_skills, range_skills, ammo, ammo_texture_path
	load_data()
	load_items()
	load_res()
	reload_menu()
	if in_battle:
		$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), ammo_path, Items)
		$AttackMenu.visible = true
		if KnockedUp:
			can_be_attacked = false
			animationState.travel("knocked_down")
		elif current_style == "melee":
			animationState.travel("melee_idle")
		elif current_style == "range":
			animationState.travel("range_idle")
	else:
		$AttackMenu.visible = false


func reload_menu():
	$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), ammo_path, Items)


func get_damage(attack):
	if wait_timer != null:
		wait_timer.set_paused(true)
	animationState.travel("get_damage")
	Hp -= attack.damage
	if Hp < 0:
		Hp = 0
	
	$BattleSounds.stream = load("res://Music/Sfx/Combat/Getting_damage_2_sfx.wav")
	$BattleSounds.play()
	$AttackMenu/HBoxContainer/RightMenu/HealthBar.value = Hp
	
	if wait_timer != null:
		wait_timer.set_paused(false)
	if Hp <= 0:
		KnockedUp = true
		can_be_attacked = false
	else:
		$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), ammo_path, Items)
	
	print(ready_to_attack_bool)
	if ready_to_attack_bool:
		reset_attack.emit()
		if !in_tutorial:
			unlock_buttons()
		$AttackMenu/HBoxContainer/LeftMenu/AttackButton.release_focus()
		$AttackMenu/HBoxContainer/LeftMenu/SkillsButton.release_focus()
		$AttackMenu/HBoxContainer/LeftMenu/ItemsButton.release_focus()

func _process(delta):
	if in_tutorial:
		$AttackMenu.in_tutorial = true
	if in_battle:
		$PlayerBody/Collision.disabled = false
		$PlayerBody/LevelCollider.disabled = true
		if KnockedUp:
			$AttackMenu.visible = false
			animationState.travel("knocked_down")
		else:
			$AttackMenu.visible = true
		
		if ready_to_attack_bool:
			if Input.is_action_just_pressed("cancel"):
				reset_attack.emit()
				#unlock_buttons()
				
		
		if timer != null:
			if duringSkillCheck:
				if current_style == "melee":
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

#args = akcja do wykonania
#dla itemu przechowuje cały obiekt itemu
#dla skilla cały obiekt skilla
#dla ataku null
func _on_attack_menu_i_will_attack(args):
	ready_to_attack_bool = true
	lock_buttons()
		#------------------podstawowy atak zależny od stylu----------------------
	var attack_index = 0
	if args == null:
		for attack in Attacks:
				if(attack.type == current_style):
					attack_index = Attacks.find(attack)
		var current_attack = Attacks[attack_index]
		
		# Jeżeli aktualny efekt == "stronger" to zwiększ damage tego ataku
		if current_effect_working != null and current_effect_working == "stronger":
			current_attack.damage *= effect_multipler
			effect_counter -= 1
			if effect_counter <= 0:
				current_effect_working = null
				effect_multipler = null
				effect_counter = 0
				
		ready_to_attack.emit(current_attack, self)
	else:
		if args.has("effect"):
			if args.effect == "revive":
				ready_to_attack.emit({"name": args.name, "damage": args.damage, "wait_time": 3, "heal": args.heal, "key": args.name, "effect": args.effect}, self)
			elif args.effect == "stronger":
				ready_to_attack.emit({"wait_time": args.wait_time, "effect": args.effect, "heal": args.heal, "effect_duration": args.turn_duration, "effect_multipler": args.attack_multiplier}, self)
			else:
				ready_to_attack.emit({"name": args.name, "damage": args.damage, "wait_time": 3, "heal": args.heal, "key": args.name, "effect": args.effect},  self)
		else:
			var damage = args.damage
			if current_effect_working != null and current_effect_working == "stronger":
				damage = damage * effect_multipler
				effect_counter -= 1
				if effect_counter <= 0:
					current_effect_working = null
					effect_multipler = null
					effect_counter = 0
			if len(args) == 8:
				ready_to_attack.emit({"damage": damage, "wait_time": args.wait_time, "effect": args.effect}, self)
			elif len(args) == 9:
				if args.effect != current_effect_working:
					ready_to_attack.emit({"damage": damage, "wait_time": args.wait_time, "effect": args.effect, "effect_duration": args.turn_duration, "effect_multipler": args.attack_multiplier}, self)
			else:
				ready_to_attack.emit({"damage": damage, "wait_time": args.wait_time}, self)

func start_attack(attack):
	print("ATTACKING")
	ready_to_attack_bool = false
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = float(attack.wait_time)
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	if current_style == "melee":
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
				$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), ammo_path, Items)
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
				$RangeSound.play()
				selected_attack = attack
				attacking.emit(selected_attack)
				decrement_ammo()
				$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), ammo_path, Items)
				return
			elif attack.effect == "stronger":
				selected_attack = attack
				current_effect_working = attack.effect
				effect_multipler = attack.effect_multipler
				effect_counter = attack.effect_duration
				$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), ammo_path, Items)
				_on_attack_done()
				return
				
	duringSkillCheck = true
	selected_attack = attack
	timer.start()
	
func start_using_item():
	if !in_tutorial:
		unlock_buttons()
	can_be_checked = false
	ready_to_attack_bool = false
	var item = get_parent().possible_attack
	load_items()
	$AttackMenu.load_data(Hp, MaxHp, {}, get_ammo(), ammo_path, Items)
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
		print("FAILED")
		skillCheckFailed = true
		duringSkillCheck = false
		can_be_attacked = true
		attacking.emit({"damage": 0})
		if current_style == "range":
			decrement_ammo()
			$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), ammo_path, Items)
			$RangeSKillCheck.started = false
			$RangeSKillCheck.visible = false
		timer.queue_free()
	else:
		if skillCheckStep == len(skillChecks) - 1 or skillCheckStep == -1:
			duringSkillCheck = false
			print("CORRECT")
			attacking.emit(selected_attack)
			if current_style == "range":
				$RangeSound.play()
				decrement_ammo()
				$AttackMenu.load_data(Hp, MaxHp, Skills, get_ammo(), ammo_path, Items)
				animationState.travel("range_attack")
			else:
				$BattleSounds.stream = load("res://Music/Sfx/Combat/Melee_combat_sfx.wav")
				$BattleSounds.play()
				animationState.travel("melee_attack")
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
	if !in_tutorial:
		unlock_buttons()
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
		if current_style == "melee":
			if Name != "Shadow":
				animationState.travel("show_melee")
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
	if current_style == "melee":
		if Name != "Shadow":
			animationState.travel("hide_melee")
	else:
		animationState.travel("hide_range")
	print("FUCKING EMIT")
	print(in_tutorial)
	if in_tutorial:
		print("FUCKING EMIT")
		tutorial_change_signal.emit()
		
func revive(heal):
	KnockedUp = false
	animationState.travel(str(current_style) + "_idle")
	
func use_item(item_to_use):
	if(item_to_use.has("effect")):
		if item_to_use.effect == ("revive"):
			revive(item_to_use.heal)
	
	if(item_to_use.has("attack")):
		if item_to_use.damage != 0:
			Hp -= item_to_use.damage
		
	elif item_to_use.heal != 0:
		$BattleSounds.stream = load("res://Music/Sfx/Combat/Heal_sfx.wav")
		$BattleSounds.play()
		Hp += item_to_use.heal
		if Hp > MaxHp:
			Hp = MaxHp
	
	
	var index = -1
	var i = 0
	for item in Items:
		if(item.name == item_to_use.name):
			item.amount -= 1
		if(item.amount <= 0):
			index = i
		i += 1
	
	if(index != -1):
		Items.remove_at(index)
	
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
		
func unshow_checksprite():
	$CheckSprite.visible = false

func unlock_buttons():
	$AttackMenu.unlock_buttons()
	
func lock_buttons():
	$AttackMenu.lock_buttons()
	
func unlock_specific_button(name):
	$AttackMenu.unlock_specific_button(name)
	
func lock_change_button():
	$AttackMenu.lock_change_style()

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "hide_melee" or anim_name == "hide_range":
		animationState.travel("change_style")
	elif anim_name == "show_melee":
		animationState.travel("melee_idle")
	elif anim_name == "show_range":
		animationState.travel("range_idle")
	elif anim_name == "melee_attack":
		can_be_attacked = true
		animationState.travel("melee_idle")
	elif anim_name == "range_attack":
		can_be_attacked = true
		if Name != "Mikut" and Name != "Shadow":
			animationState.travel("reload")
		else:
			animationState.travel("change_style")
	elif anim_name == "get_damage":
		if current_style == "melee":
			animationState.travel("melee_idle")
		else:
			if waiting:
				animationState.travel("change_style")
			else:
				animationState.travel("range_idle")
	elif anim_name == "use_item":
		if current_style == "melee":
			if waiting:
				animationState.travel("change_style")
			else:
				animationState.travel("melee_idle")
		else:
			if waiting:
				animationState.travel("change_style")
			else:
				animationState.travel("range_idle")
	elif anim_name == "reload":
		animationState.travel("hide_range")
