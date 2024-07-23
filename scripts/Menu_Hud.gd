extends CanvasLayer

@onready var profile = preload("res://Scenes/Menus/Profile.tscn")
var Items
var Skills
var PartyEq
var PersonEq
var eq_temp_person
var Teammates
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
		
		new_profile.load_data(temp_data.name, temp_data.hp, temp_data.max_hp)
		new_profile.selectTeammate.connect(_on_entityChossed)
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.add_child(new_profile)
		
func refresh_data():
	var text = FileAccess.get_file_as_string("res://Data/party_data.json")
	var res_text = FileAccess.get_file_as_string("res://Data/party_resources.json")
	var craft_text = FileAccess.get_file_as_string("res://Data/crafting_recipies.json") 
	
	var temp_data = JSON.parse_string(text)
	var temp_res = JSON.parse_string(res_text)
	var temp_craft = JSON.parse_string(craft_text)
	
	Items = temp_data["items"]
	Teammates = temp_data["teammates"]
	PartyEq = temp_data["equipment"]
	PartyResources = temp_res
	CraftingRecipies = temp_craft
	add_items()

func saveData():
	var file = FileAccess.open("res://Data/party_data.json", FileAccess.WRITE)
	var res_file = FileAccess.open("res://Data/party_resources.json", FileAccess.WRITE)
	var temp_data = {
		"teammates": Teammates,
		"items": Items,
		"equipment": PartyEq
	}
	
	file.store_string(JSON.stringify(temp_data, "\t", false))
	file.close()
	res_file.store_string(JSON.stringify(PartyResources, "\t", false))
	res_file.close()

func add_items():
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/ItemList.clear()
	for key in Items:
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/ItemList.add_item(str(key).replace("_", " "))
		
func add_resources():
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Bottom/Resources/ScrollContainer/VBoxContainer/ResourcesList.clear()
	for key in PartyResources:
		var temp_resource = PartyResources[key]
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Bottom/Resources/ScrollContainer/VBoxContainer/ResourcesList.add_item(str(key).replace("_", " ") + " " + str(PartyResources[key].ammount) + "x")

func add_recipies():
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Bottom/Recipes/ScrollContainer/VBoxContainer/RecipesList.clear()
	for key in CraftingRecipies:
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Craft/Bottom/Recipes/ScrollContainer/VBoxContainer/RecipesList.add_item(str(key).replace("_", " "))

func _ready():
	var text = FileAccess.get_file_as_string("res://Data/party_data.json")
	var temp_data = JSON.parse_string(text)
	Items = temp_data["items"]
	Teammates = temp_data["teammates"]
	PartyEq = temp_data["equipment"]
	print(Items)
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
			eq_temp_person = temp_teammate.instantiate()
			eq_temp_person.load_data()
			PersonEq = eq_temp_person.get_eq()
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.clear()
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.clear()
			for key in PersonEq:
				$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.add_item(str(key)+": "+str(PersonEq[key][0]).replace("_", " "))
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/EqProfile.load_data(eq_temp_person.get_entity_name(), eq_temp_person.get_hp(), eq_temp_person.get_max_hp())
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


func _on_self_equipment_item_activated(index):
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.clear()
	Eq_to_be_changed_index = index
	var eq_category = $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.get_item_text(index).split(":")[0]
	
	for key in PartyEq.keys():
		if PartyEq[key][1] == eq_category: 
			$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.add_item(key.replace("_", " "))
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.add_item(" ")


func _on_equipment_item_activated(index):
	var to_change_key = $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.get_item_text(index) 
	var to_be_changed = $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.get_item_text(Eq_to_be_changed_index) 
	var to_change #party eq
	var to_be_changed_item #person eq

	if to_change_key != " ":
		to_change = PartyEq[to_change_key.replace(" ", "_")][1]
		to_be_changed_item = PersonEq[to_be_changed.split(":")[0]]

		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.set_item_text(Eq_to_be_changed_index, to_change + ": " + to_change_key.replace("_", " "))
		if len(PartyEq[to_change_key.replace(" ", "_")]) > 3:
			PersonEq[to_change] = [to_change_key, PartyEq[to_change_key.replace(" ", "_")][0], PartyEq[to_change_key.replace(" ", "_")][2], PartyEq[to_change_key.replace(" ", "_")][3]]
		else:
			PersonEq[to_change] = [to_change_key, PartyEq[to_change_key.replace(" ", "_")][0], PartyEq[to_change_key.replace(" ", "_")][2]]
	else:
		to_be_changed_item = PersonEq[to_be_changed.split(":")[0]]
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/HBoxContainer/SelfEquipment.set_item_text(Eq_to_be_changed_index, to_be_changed.split(":")[0] + ": ")
		if len(to_be_changed_item) > 3:
			PersonEq[to_be_changed.split(":")[0]] = ["", "", 0, 0]
		else:
			PersonEq[to_be_changed.split(":")[0]] = ["", "", 0]
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Eq/Equipment.set_item_text(index, to_be_changed)
	
	PartyEq.erase(to_change_key.replace(" ", "_"))
	
	if to_be_changed != "Armor: " and to_be_changed != "Mele_weapon: " and to_be_changed != "Range_weapon: ":
		print("TEN DZIWNY KURWA IF")
		if len(to_be_changed_item) > 3:
			PartyEq[to_be_changed.split(": ")[1].replace(" ", "_")] =  [to_be_changed_item[1], to_be_changed.split(":")[0], to_be_changed_item[2], to_be_changed_item[3]]
		else:
			PartyEq[to_be_changed.split(": ")[1].replace(" ", "_")] =  [to_be_changed_item[1], to_be_changed.split(":")[0], to_be_changed_item[2]]

	saveData()
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
		PartyResources[c].ammount -= 1
		if PartyResources[c].ammount <= 0:
			PartyResources.erase(c)

	if temp_recipe.type != "item":
		if temp_recipe.type == "Range_weapon":
			var has_weapon = false
			for teammate in Teammates:
				var text = FileAccess.get_file_as_string(teammate)
				var temp_data = JSON.parse_string(text)
				if temp_data.equipment.Range_weapon[0] == temp_recipe.data[0]:
					temp_data.equipment.Range_weapon[3] += 1
					var file = FileAccess.open(teammate, FileAccess.WRITE)
					file.store_string(JSON.stringify(temp_data, "\t", false))
					file.close()
					has_weapon = true
			for e in PartyEq:	
				if e == temp_recipe.data[0].replace(" ", "_"):
					PartyEq[e][3] += 1
					has_weapon = true
			if !has_weapon:
				PartyEq[temp_recipe.data[0].replace(" ", "_")] = [temp_recipe.data[1], temp_recipe.type, temp_recipe.data[2], 1]
		else:
			PartyEq[temp_recipe.data[0].replace(" ", "_")] = [temp_recipe.data[1], temp_recipe.type, temp_recipe.data[2]]
	else:
		var has_item = false
		for item in Items:
			if item == temp_recipe.data[0]:
				has_item = true
				Items[item][3] += 1
		if !has_item:
			if len(temp_recipe.data) == 4:
				Items[temp_recipe.data[0]] = [temp_recipe.data[1], temp_recipe.data[2], temp_recipe.data[3], 1]
			else:
				Items[temp_recipe.data[0]] = [temp_recipe.data[1], temp_recipe.data[2], temp_recipe.data[3], 1, temp_recipe.data[4]]
	saveData()
	refresh_data()
	add_resources()
	add_recipies()
	load_profiles()
