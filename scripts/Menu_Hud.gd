extends CanvasLayer

@onready var profile = preload("res://Scenes/Menus/Profile.tscn")
var Items
var Skills
var PartyEq
var PersonEq
var Teammates
var item_to_use
var using_item = false
signal itemUsed(item_name, entity_name)


func load_profiles():
	for teammate in Teammates:
		var text = FileAccess.get_file_as_string(teammate)
		var temp_data = JSON.parse_string(text)
		var new_profile = profile.instantiate()
		
		new_profile.load_data(temp_data.name, temp_data.hp, temp_data.max_hp)
		new_profile.selectTeammate.connect(_on_entityChossed)
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.add_child(new_profile)
		
func refresh_data():
	var text = FileAccess.get_file_as_string("res://Data/party_data.json")
	var temp_data = JSON.parse_string(text)
	Items = temp_data["items"]
	Teammates = temp_data["teammates"]
	PartyEq = temp_data["equipment"]
	add_items()

func add_items():
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/ItemList.clear()
	for key in Items:
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/ItemList.add_item(str(key).replace("_", " "))

func _ready():
	var text = FileAccess.get_file_as_string("res://Data/party_data.json")
	var temp_data = JSON.parse_string(text)
	Items = temp_data["items"]
	Teammates = temp_data["teammates"]
	print(Items)
	load_profiles()
	add_items()

func _process(delta):
	pass

func unshowCards():
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items.visible = false
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = false
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills.visible = false
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq.visible = false
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/HBoxContainer/ItemDesc.text = ""
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/HBoxContainer/ItemAmmount.text = ""
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills/HBoxContainer/SkillCost.text = ""
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills/HBoxContainer/SkillDesc.text = ""

func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	var item = Items.keys()[index]
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/HBoxContainer/ItemDesc.text = Items[item][0]
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/HBoxContainer/ItemAmmount.text = "Ammount: " + str(Items[item][3])


func _on_item_list_item_activated(index):
	item_to_use = Items.keys()[index]
	using_item = true
	for profile in $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.get_children():
		profile.unlock_choosing("item")
	unshowCards()
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = true


func _on_button_pressed():
	if !using_item:
		if $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items.visible:
			unshowCards()
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = true
			$Control/MarginContainer/HBoxContainer/Buttons/Button.release_focus()
		else:
			unshowCards()
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items.visible = true
			
	
func showSkills(entity_name):
	if entity_name == "Player":
		entity_name = "Mikut"
	for teammate in Teammates:
		
		if teammate.contains(entity_name.to_lower()):
			if entity_name == "Mikut":
				entity_name = "Player"
			#mój programistyczny peak - nie wytłumaczę domyśl się sam lol
			var temp_teammate = load("res://Scenes/Actors/"+str(entity_name)+".tscn")
			var temp_instance = temp_teammate.instantiate()
			temp_instance.load_data()
			Skills = temp_instance.get_skills()
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills/SkillList.clear()
			for key in Skills:
				$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills/SkillList.add_item(str(key).replace("_", " "))
	for profile in $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.get_children():
		profile.lock_choosing()
	unshowCards()
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills.visible = true
	using_item = false
	
func showEq(entity_name):
	var load_name = entity_name
	if entity_name == "Mikut":
		load_name = "Player"
	print(entity_name)
	for teammate in Teammates:
		if teammate.contains(entity_name.to_lower()):
			print()
			var temp_teammate = load("res://Scenes/Actors/"+str(load_name)+".tscn")
			var temp_instance = temp_teammate.instantiate()
			temp_instance.load_data()
			PersonEq = temp_instance.get_eq()
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.clear()
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.clear()
			for key in PersonEq:
				$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.add_item(str(key)+": "+str(PersonEq[key][0]).replace("_", " "))
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/EqProfile.load_data(temp_instance.get_entity_name(), temp_instance.get_hp(), temp_instance.get_max_hp())
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/EqProfile.set_values()
	for profile in $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.get_children():
		profile.lock_choosing()
	unshowCards()
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq.visible = true
	using_item = false

func _on_entityChossed(entity_name, choosingActions):
	if choosingActions == "item":
		itemUsed.emit(item_to_use, entity_name)
	elif choosingActions == "skill":
		showSkills(entity_name)
	elif choosingActions == "eq":
		print(entity_name)
		showEq(entity_name)


func _on_world_item_done():
	using_item = false
	unshowCards()
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = true
	refresh_data()
	
	for profile in $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.get_children():
		
		profile.lock_choosing()
		for teammate in Teammates:
			if teammate.contains(profile.Name.to_lower()):
				var text = FileAccess.get_file_as_string(teammate)
				var temp_data = JSON.parse_string(text)
				profile.load_data(temp_data.name, temp_data.hp, temp_data.max_hp)
				profile.set_values()



func _on_skills_pressed():
	if !$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills.visible:
		for profile in $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.get_children():
			profile.unlock_choosing("skill")
		unshowCards()
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = true
	else:
		unshowCards()
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = true
		$Control/MarginContainer/HBoxContainer/Buttons/Skills.release_focus()


func _on_skill_list_item_clicked(index, at_position, mouse_button_index):
	var skill = Skills.keys()[index]
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills/HBoxContainer/SkillDesc.text = Skills[skill][0]
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills/HBoxContainer/SkillCost.text = "Cost: " + str(Skills[skill][3])


func _on_eq_pressed():
	if !$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq.visible:
		for profile in $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.get_children():
			profile.unlock_choosing("eq")
		unshowCards()
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = true
	else:
		unshowCards()
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = true
		$Control/MarginContainer/HBoxContainer/Buttons/EqB.release_focus()
