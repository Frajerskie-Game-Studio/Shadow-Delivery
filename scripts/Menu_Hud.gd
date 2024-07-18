extends CanvasLayer

@onready var profile = preload("res://Scenes/Menus/Profile.tscn")
var Items

func load_profiles(teammates):
	for teammate in teammates:
		var text = FileAccess.get_file_as_string(teammate)
		var temp_data = JSON.parse_string(text)
		var new_profile = profile.instantiate()
		
		new_profile.load_data(temp_data.name, temp_data.hp)
		
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles .add_child(new_profile)

func add_items():
	for item in Items:
		var key = item.keys()[0]
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/ItemList.add_item(str(key).replace("_", " "))

func _ready():
	var text = FileAccess.get_file_as_string("res://Data/party_data.json")
	var temp_data = JSON.parse_string(text)
	Items = temp_data["items"]
	load_profiles(temp_data["teammates"])
	add_items()

func _process(delta):
	pass

func unshowCards():
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items.visible = false
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = false

func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	var item = Items[index]
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/HBoxContainer/ItemDesc.text = item[item.keys()[0]][0]
	$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items/HBoxContainer/ItemAmmount.text = "Ammount: " + str(item[item.keys()[0]][3])


func _on_item_list_item_activated(index):
	print("active")


func _on_button_pressed():
	if $Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items.visible:
		unshowCards()
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Profiles.visible = true
	else:
		unshowCards()
		$Control/MarginContainer/HBoxContainer/Panel/MarginContainer/Items.visible = true
		
