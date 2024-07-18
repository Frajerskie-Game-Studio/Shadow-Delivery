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

func _ready():
	var text = FileAccess.get_file_as_string("res://Data/party_data.json")
	var temp_data = JSON.parse_string(text)
	Items = temp_data["items"]
	load_profiles(temp_data["teammates"])
	

func _process(delta):
	pass
