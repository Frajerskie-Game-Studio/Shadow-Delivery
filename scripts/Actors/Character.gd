extends Node2D


var Name
var Hp
var MaxHp
var Skills
var Equipment
var Attacks
var Items
var Resources
var Party_Data
var KnockedUp
var ProfileTexture

var character_file_path
var effect_counter = 0
var effect_multipler = 0
var in_battle = false
var duringSkillCheck = false
var skillCheckFailed = true
var waiting = false
var can_be_attacked = true
var ready_to_attack_bool = false
var changing_style = false
var can_be_checked = false
var on_mouse_cursor = false
var selected_attack
var current_style = "melee"


signal ready_to_attack()
signal attacking
signal reset_attack
signal item_being_used()


func save_items():
	var file = FileAccess.open("res://Data/party_data.json", FileAccess.WRITE)
	var temp_data = {
		"teammates": Party_Data.teammates,
		"teammates_nodes": Party_Data.teammates_nodes,
		"items": Items,
		"equipment": Party_Data.equipment
	}
	file.store_string(JSON.stringify(temp_data, "\t", false))
	file.close()
	
func save_resources():
	var file = FileAccess.open("res://Data/party_resources.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(Resources, "\t", false))
	file.close()


func save_data():
	var file = FileAccess.open(character_file_path, FileAccess.WRITE)
	var temp_data = {
		"name": Name,
		"texture": ProfileTexture,
		"hp": Hp,
		"max_hp": MaxHp,
		"knocked_up": KnockedUp,
		"attacks": Attacks,
		"skills": Skills,
		"equipment": Equipment
	}
	file.store_string(JSON.stringify(temp_data, "\t", false))
	file.close()


func load_data():
	var text = FileAccess.get_file_as_string(character_file_path)
	var temp_data = JSON.parse_string(text)
	Name = temp_data.name
	Hp = temp_data.hp
	MaxHp = temp_data.max_hp
	Skills = temp_data.skills
	Equipment = temp_data.equipment
	Attacks = temp_data.attacks
	KnockedUp = temp_data.knocked_up
	ProfileTexture = temp_data.texture


func load_items():
	var text = FileAccess.get_file_as_string("res://Data/party_data.json")
	var temp_data = JSON.parse_string(text)
	Items = temp_data.items
	Party_Data = temp_data
	
func load_res():
	var text = FileAccess.get_file_as_string("res://Data/party_resources.json")
	var temp_data = JSON.parse_string(text)
	Resources = temp_data


func _ready():
	print("READY")
	load_data()
	load_items()
	load_res()
	can_be_attacked = true


func get_ammo():
	return Equipment.Range_weapon.ammo


func decrement_ammo():
	Equipment.Range_weapon.ammo -= 1


func add_ammo():
	Equipment.Range_weapon.ammo += 1


func get_style():
	return current_style


func set_style():
	if current_style == "melee":
		current_style = "range"
	else:
		current_style = "melee"

func get_attack():
	return Attacks


func get_entity_name():
	return Name


func get_skills():
	return Skills


func get_hp():
	return Hp


func get_max_hp():
	return MaxHp


func get_eq():
	return Equipment


func set_eq(eq):
	Equipment = eq
	save_data()


func _process(delta):
	pass
