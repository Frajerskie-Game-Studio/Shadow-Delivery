extends Node

var Party = []
var Enemies = []

var possible_attack
var possible_attacker
var possible_target
var possible_effect

var battle_drop = []
signal end_whole_battle
@onready var Positions = {
	"party": [
		$Party_Second_Position,
		$Party_First_Position,
		$Party_Fourth_Position,
		$Party_Third_Position,
	],
	"enemy": [
		$Enemy_Second_Position,
		$Enemy_First_Position,
		$Enemy_Third_Position,
		$Enemy_Fourth_Position
	]
}


func _ready():
	pass


func _process(delta):
	var counter = 0
	for p in Party:
		if p.KnockedUp:
			counter+=1
	if counter == len(Party):
		get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

func load_entities(party, enemies):
	for index in range(len(party)):
		var temp_load = load(party[index])
		Party.append(temp_load.instantiate())
		Party[index].in_battle = true
		Party[index].position = Positions.party[index].position
		Party[index].ready_to_attack.connect(_on_entity_ready_to_attack)
		Party[index].attacking.connect(_on_attacking_entity)
		Party[index].reset_attack.connect(_on_reset_ready_to_attack)
		Party[index].item_being_used.connect(_on_item_being_used)
		if(Party[index].has_method("lock")):
			Party[index].lock()
		Party[index].load_items()
		Party[index].load_res()
		add_child(Party[index])	
		
	for index in range(len(enemies)):
		var temp_load = load("res://Scenes/Actors/Enemy.tscn")
		Enemies.append(temp_load.instantiate())
		Enemies[index].load_data(enemies[index])
		Enemies[index].position = Positions.enemy[index].position
		Enemies[index].being_attacked.connect(_on_entity_being_attacked)
		Enemies[index].enemy_attacking.connect(_on_enemy_attacking)
		Enemies[index].dying.connect(_on_enemy_dying)
		add_child(Enemies[index])
		battle_drop.append(Enemies[index].get_drop())
		Enemies[index].start_attacking_process()

func _on_entity_ready_to_attack(attack, attacker):
	possible_attack = attack
	possible_attacker = attacker
	if !possible_attack.has("heal"):
		for e in Enemies:
			e.attack_danger = true
	else:		
		for p in Party:
			if possible_attack.has("effect") and possible_attack.effect == "revive":
				if p.KnockedUp:
					p.can_be_checked = true
			else:
				p.can_be_checked = true
			
	if possible_attack.has("effect"):
		if possible_attack.effect == "all":
			for e in Enemies:
				e.all_attack()
		elif possible_attack.effect == "stronger":
			possible_attacker.start_attack(possible_attack)
		

func _on_reset_ready_to_attack():
	if possible_attacker != null and !possible_attacker.KnockedUp:
		possible_attack = null
		possible_attacker.can_be_attacked = true
		possible_attacker = null

	for e in Enemies:
		e.attack_danger = false
	
	for p in Party:
		p.can_be_checked = false
		p.on_mouse_cursor = false
		
func _on_entity_being_attacked(entity):
	print("ATTACKED")
	print(possible_attacker)
	possible_attacker.can_be_attacked = false
	for e in Enemies:
		e.attack_danger = false
	possible_target = entity
	possible_attacker.start_attack(possible_attack)
	
func _on_attacking_entity(attack):
	possible_target.get_damage(attack)
	possible_attacker._on_attack_done()
	
func get_can_be_attack_entities():
	var can_be_attacked_array = []
	for teammate in Party:
		if teammate.can_be_attacked:
			can_be_attacked_array.append(teammate)
	return can_be_attacked_array
	
func _on_item_being_used(entity):
	entity.use_item(possible_attack)
	entity.reload_menu()
	possible_attacker.start_using_item()

func _on_enemy_attacking(target, attack):
	target.get_damage(attack)
	
func _on_enemy_dying(entity):
	for e in Enemies:
		if e == entity:
			Enemies.erase(e)
			e.queue_free()
	if len(Enemies) == 0:
		end_battle()

func end_battle():
	$AudioStreamPlayer2D.stream = load("res://Music/Sfx/Win_sfx.wav")
	$AudioStreamPlayer2D.play()
	var temp_entity = Party[0]
	temp_entity.load_res()
	for loot in battle_drop:
		if loot != null:
			if typeof(loot) != TYPE_ARRAY:
				if loot.type == "item":
					var has_item = false
					for item in temp_entity.Items:
						if item == loot.name:
							temp_entity.Items[item][3] += loot.data[3]
							has_item = true
					if !has_item:
						temp_entity.Items[loot.name] = {loot.name :loot.data}
						$CanvasLayer/DropMenu/Panel/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ItemList.add_item(loot.name + " x" + str(loot.data[3]))
				elif loot.type == "resource":
					var has_res = false
					for res in temp_entity.Resources:
						if res == loot.name:
							temp_entity.Resources[res].ammount += loot.data.ammount
							has_res = true
					if !has_res:
						temp_entity.Resources[loot.name] = {"ammount": loot.data.ammount, "texture": loot.data.texture}
					$CanvasLayer/DropMenu/Panel/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ItemList.add_item(loot.name + " x" + str(loot.data.ammount))
			else:
				for inside_loot in loot:
					if inside_loot != null:
						if inside_loot.type == "item":
							var has_item = false
							for item in temp_entity.Items:
								if item == inside_loot.name:
									temp_entity.Items[item][3] += inside_loot.data[3]
									has_item = true
							if !has_item:
								temp_entity.Items[inside_loot.name] = {inside_loot.name :inside_loot.data}
							$CanvasLayer/DropMenu/Panel/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ItemList.add_item(inside_loot.name + " x" + str(inside_loot.data[3]))
						elif inside_loot.type == "resource":
							var has_res = false
							for res in temp_entity.Resources:
								if res == inside_loot.name:
									temp_entity.Resources[res].ammount += inside_loot.data.ammount
									has_res = true
							if !has_res:
								temp_entity.Resources[inside_loot.name] = {"ammount": inside_loot.data.ammount, "texture": inside_loot.data.texture}
							$CanvasLayer/DropMenu/Panel/VBoxContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ItemList.add_item(inside_loot.name + " x" + str(inside_loot.data.ammount))
	temp_entity.save_data()
	temp_entity.save_resources()
	temp_entity.save_items()
	temp_entity.load_data()
	temp_entity.load_items()
	temp_entity.load_res()
	for t in Party:
		t.save_data()
		t.save_resources()
		t.save_items()
		t.in_battle = false
	$CanvasLayer/DropMenu.visible = true

func _on_drop_menu_end_fight():
	$BattleCamera.enabled = false
	end_whole_battle.emit()
