extends CanvasLayer

@onready var profile = preload("res://Scenes/Menus/Profile.tscn")
var Items
var Skills
var PartyEq
var PersonEq
var eq_temp_person
var Teammates
var TeammatesNodes
var PartyResources
var CraftingRecipies
var item_to_use
var Eq_to_be_changed_index
var using_item = false
var temp_recipe
signal itemUsed(item_name, entity_name)
signal saveEq(entity_name)

func load_profiles():
	for child in $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.get_children():
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.remove_child(child)
	
	for teammate in Teammates:
		var text = FileAccess.get_file_as_string(teammate)
		var temp_data = JSON.parse_string(text)
		var new_profile = profile.instantiate()
		
		new_profile.load_data(temp_data.name, temp_data.hp, temp_data.max_hp, temp_data.texture, temp_data.knocked_up)
		new_profile.selectTeammate.connect(_on_entityChossed)
		
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.add_child(new_profile)
		
func refresh_data():
	var text = FileAccess.get_file_as_string("user://Data/party_data.json")
	var res_text = FileAccess.get_file_as_string("user://Data/party_resources.json")
	var craft_text = FileAccess.get_file_as_string("user://Data/crafting_recipies.json") 
	
	var temp_data = JSON.parse_string(text)
	var temp_res = JSON.parse_string(res_text)
	var temp_craft = JSON.parse_string(craft_text)
	
	Items = temp_data.items
	Teammates = temp_data.teammates
	TeammatesNodes = temp_data.teammates_nodes
	PartyEq = temp_data.equipment
	PartyResources = temp_res
	CraftingRecipies = temp_craft
	add_items()

func save_data():
	var file = FileAccess.open("user://Data/party_data.json", FileAccess.WRITE)
	var res_file = FileAccess.open("user://Data/party_resources.json", FileAccess.WRITE)
	var temp_data = {
		"teammates": Teammates,
		"teammates_nodes": TeammatesNodes,
		"items": Items,
		"equipment": PartyEq
	}
	
	file.store_string(JSON.stringify(temp_data, "\t", false))
	file.close()
	res_file.store_string(JSON.stringify(PartyResources, "\t", false))
	res_file.close()

func add_items():
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/ItemList.clear()
	for item in Items:
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/ItemList.add_item(item.name, load(item.icon_path))


func add_resources():
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Bottom/Resources/ScrollContainer/VBoxContainer/ResourcesList.clear()
	for key in PartyResources:
		var temp_resource = PartyResources[key]
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Bottom/Resources/ScrollContainer/VBoxContainer/ResourcesList.add_item(str(key) + " " + str(PartyResources[key].amount) + "x")

func add_recipies():
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Bottom/Recipes/ScrollContainer/VBoxContainer/RecipesList.clear()
	for key in CraftingRecipies:
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Bottom/Recipes/ScrollContainer/VBoxContainer/RecipesList.add_item(str(key).replace("_", " "))

func _ready():
	var text = FileAccess.get_file_as_string("user://Data/party_data.json")
	var temp_data = JSON.parse_string(text)
	Items = temp_data["items"]
	Teammates = temp_data["teammates"]
	TeammatesNodes = temp_data["teammates_nodes"]
	PartyEq = temp_data["equipment"]
	load_profiles()
	add_items()
	refresh_data()

func _process(delta):
	pass

func unshowCards():
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items.visible = false
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = false
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills.visible = false
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq.visible = false
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft.visible = false
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/HBoxContainer/ItemDesc.text = ""
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/HBoxContainer/ItemAmmount.text = ""
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills/HBoxContainer/SkillCost.text = ""
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills/HBoxContainer/SkillDesc.text = ""
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Res2/Desc.text = ""
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Res1/Desc.text = ""
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Output/Desc.text = ""
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Res1/TextureRect.texture = null
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Res2/TextureRect.texture = null
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Output/TextureRect.texture = null

func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	var item = Items[index]
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/HBoxContainer/ItemDesc.text = Items[index].description
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/HBoxContainer/ItemAmmount.text = "Ammount: " + str(Items[index].amount)


func _on_item_list_item_activated(index):
	item_to_use = Items[index]
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
			
			for skill in Skills:
				$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills/SkillList.add_item(str(skill.name))
			
	for profile in $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.get_children():
		profile.lock_choosing()
	unshowCards()
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills.visible = true
	using_item = false
	
func showEq(entity_name):
	var load_name = entity_name
	if entity_name == "Mikut":
		load_name = "Player"
	print(load_name + str(" dix dixer rrrrrr"))
	print(entity_name + str("WOWOOW SISIAKO"))

	for teammate in Teammates:
		print(teammate.contains(entity_name.to_lower()))
		print(entity_name.to_lower())
		if teammate.contains(entity_name.to_lower()):
			var temp_teammate = load("res://Scenes/Actors/"+str(load_name)+".tscn")
			
			eq_temp_person = temp_teammate.instantiate()
			print(eq_temp_person.character_file_path)
			eq_temp_person.load_data()
			PersonEq = eq_temp_person.get_eq()
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.clear()
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.clear()
			for item_type in PersonEq:
				var item = PersonEq[item_type]
				$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.add_item(str(item_type) + ": " + item.name)
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/EqProfile.load_data(eq_temp_person.get_entity_name(), eq_temp_person.get_hp(), eq_temp_person.get_max_hp(), eq_temp_person.ProfileTexture, eq_temp_person.KnockedUp)
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
				profile.load_data(temp_data.name, temp_data.hp, temp_data.max_hp, temp_data.texture, temp_data.knocked_up)
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
	var skill = Skills[index]
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills/HBoxContainer/SkillDesc.text = skill.description
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Skills/HBoxContainer/SkillCost.text = "Cost: " + str(skill.wait_time)


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


func _on_self_equipment_item_activated(index):
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.clear()
	Eq_to_be_changed_index = index
	var eq_category = $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.get_item_text(index).split(":")[0]
	
	for item in PartyEq:
		if item.type == eq_category: 
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.add_item(item.name)
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.add_item(" ")


func _on_equipment_item_activated(index):
	var name_to_equip = $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.get_item_text(index) 
	var full_name_to_unequip = $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.get_item_text(Eq_to_be_changed_index) 
	var item_to_equip = null
	var item_to_unequip = null

	var type_to_switch = full_name_to_unequip.split(":")[0].dedent()
	var name_to_unequip = full_name_to_unequip.split(":")[1].dedent()

	for item in PartyEq:
		if item.name == name_to_equip:
			item_to_equip = item
	
	for item in PersonEq:
		if(item == type_to_switch):
			item_to_unequip = PersonEq[item]
	
	if(item_to_equip != null):
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.set_item_text(Eq_to_be_changed_index, type_to_switch + ": " + item_to_equip.name)

		if(type_to_switch == "Armor"):
			if(name_to_unequip.dedent() != ""):
				PartyEq.append({
					"name" : name_to_unequip,
					"description" : item_to_unequip.description,
					"icon_path": item_to_unequip.icon_path,
					"type" : type_to_switch,
					"armor" : item_to_unequip.armor
				})
			
			PersonEq[type_to_switch] = {
				"name" : name_to_equip,
				"description" : item_to_equip.description,
				"icon_path": item_to_equip.icon_path,
				"type" : type_to_switch,
				"armor" : item_to_equip.armor
			}

		elif(type_to_switch == "Mele_weapon" || type_to_switch == "Range_weapon" ):
			if(name_to_unequip.dedent() != ""):
				PartyEq.append({
					"name" : name_to_unequip,
					"description" : item_to_unequip.description,
					"icon_path": item_to_unequip.icon_path,
					"type" : type_to_switch,
					"damage": item_to_unequip.damage,
					"ammo" : item_to_unequip.ammo
				})
			
			PersonEq[type_to_switch] = {
					"name" : name_to_equip,
					"description" : item_to_equip.description,
					"icon_path": item_to_equip.icon_path,
					"type" : type_to_switch,
					"damage": item_to_equip.damage,
					"ammo" : item_to_equip.ammo
				}

	else:
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.set_item_text(Eq_to_be_changed_index, type_to_switch + ": ")

		PersonEq[type_to_switch] = {
					"name" : " ",
					"description" : "",
					"icon_path": "",
					"type" : ""
				}

		if(name_to_unequip.dedent() != ""):
			if(type_to_switch == "Armor"):
				PartyEq.append({
						"name" : name_to_unequip,
						"description" : item_to_unequip.description,
						"icon_path": item_to_unequip.icon_path,
						"type" : type_to_switch,
						"armor" : item_to_unequip.armor
					})
			
			elif(type_to_switch == "Mele_weapon" || type_to_switch == "Range_weapon"):
				PartyEq.append({
						"name" : name_to_unequip,
						"description" : item_to_unequip.description,
						"icon_path": item_to_unequip.icon_path,
						"type" : type_to_switch,
						"damage": item_to_unequip.damage,
						"ammo" : item_to_unequip.ammo
					})

	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.set_item_text(index, name_to_unequip)
	for i in range(len(PartyEq)):
		if(PartyEq[i].name == name_to_equip):
			PartyEq.remove_at(i)
			break

	$AudioStreamPlayer2D.stream = load("res://Music/Sfx/Dressing_sfx.wav")
	$AudioStreamPlayer2D.play()
	save_data()
	refresh_data()
	
	eq_temp_person.set_eq(PersonEq)
	saveEq.emit(eq_temp_person.get_entity_name())
	
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.release_focus()
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.clear()
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.release_focus()


func _on_craft_pressed():
	if $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft.visible:
		unshowCards()
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = true
		$Control/MarginContainer/HBoxContainer/Buttons/Craft.release_focus()
	else:
		unshowCards()
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft.visible = true
		add_recipies()
		add_resources()



func _on_recipes_list_item_clicked(index, at_position, mouse_button_index):
	var key = $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Bottom/Recipes/ScrollContainer/VBoxContainer/RecipesList.get_item_text(index)
	var recipe = CraftingRecipies[key]
	temp_recipe = recipe
	var crafting_components_data = [
		{
			"desc": $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Res1/Desc,
			"texture": $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Res1/TextureRect
		},
		{
			"desc": $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Res2/Desc,
			"texture": $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Res2/TextureRect
		},
		{
			"desc": $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Output/Desc,
			"texture": $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Top/Output/TextureRect
		}
	]
	
	for i in range(len(temp_recipe.components)):
		var component = temp_recipe.components[i]
		if PartyResources.has(component):
			crafting_components_data[i].desc.text = component
			crafting_components_data[i].texture.texture = null #tutaj będzie tekstura z PatyResources[component].texture
		else:
			crafting_components_data[i].desc.text = str(component) + "\nnot avilable"
			return
	crafting_components_data[2].desc.text = key
	crafting_components_data[2].texture.texture = null #tutaj będzie texture pobierany z temp_recipe
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Middle/CraftButton.disabled = false


func _on_craft_button_pressed():
	#usuwanie resourców z lokalnej ZMiennej partyResource
	
	for c in temp_recipe.components:
		if(!PartyResources.has(c)):
			print_debug("brak składnika w resourcach")
			return
	
	for c in temp_recipe.components:
		PartyResources[c].amount -= 1
		if PartyResources[c].amount <= 0:
			PartyResources.erase(c)

	if temp_recipe.type != "item":
		if temp_recipe.type == "Range_weapon":
			var has_weapon = false
			for teammate in Teammates:
				var text = FileAccess.get_file_as_string(teammate)
				var temp_data = JSON.parse_string(text)
				if temp_data.equipment.Range_weapon.name == temp_recipe.data[0]:
					temp_data.equipment.Range_weapon.ammo += 1
					var file = FileAccess.open(teammate, FileAccess.WRITE)
					file.store_string(JSON.stringify(temp_data, "\t", false))
					file.close()
					has_weapon = true
			for i in range(len(PartyEq)):	
				if PartyEq[i].name == temp_recipe.data[0]:
					PartyEq[i].ammo += 1
					has_weapon = true
			if !has_weapon:
				PartyEq.append({"name": temp_recipe.data[0], "description": temp_recipe.data[1],"type": temp_recipe.type, "damage": temp_recipe.data[2], "amount": 1})
		elif temp_recipe.type == "resource":
			var has_resource = false
			for res in PartyResources:
				if res == temp_recipe.data[0]:
					PartyResources[res].amount += 1
					has_resource = true
			if !has_resource:
				PartyResources[temp_recipe.data[0]] = {"amount": 1, "texture": temp_recipe.texture}
		else:
			PartyEq.append({"name" : temp_recipe.data[0], "description": temp_recipe.data[1], "type": temp_recipe.type, "damage": temp_recipe.data[2]})
	else:
		var has_item = false
		for i in range(len(Items)):
			if Items[i].name == temp_recipe.data[0]:
				has_item = true
				Items[i].amount += 1
		if !has_item:
			if len(temp_recipe.data) == 4:
				Items.append({"name": temp_recipe.data[0], "description": temp_recipe.data[1], "icon_path": "", "damage": temp_recipe.data[2], "heal": temp_recipe.data[3], "amount": 1})
			else:
				Items.append({"name": temp_recipe.data[0], "description": temp_recipe.data[1], "icon_path": "", "damage": temp_recipe.data[2], "heal": temp_recipe.data[3], "effect": temp_recipe.data[3], "amount": 1})

	
	save_data()
	refresh_data()
	add_resources()
	add_recipies()
	load_profiles()


func _on_exit_button_pressed():
	get_tree().quit()
