extends Node




func _ready():
	var files_to_create = [
		"user://Data/battle_dialog.json",
		"user://Data/crafting_recipies.json",
		"user://Data/darkslime_data.json",
		"user://Data/desk.json",
		"user://Data/door_dialog.json",
		"user://Data/factory_lucjan_dialog.json",
		"user://Data/factory_master_dialog.json",
		"user://Data/health_furnance_dialog.json",
		"user://Data/krzychu_data.json",
		"user://Data/level_saves.json",
		"user://Data/lucjan_data.json",
		"user://Data/michal_data.json",
		"user://Data/mikut_data.json",
		"user://Data/npc_test.json",
		"user://Data/outside_door_dialog.json",
		"user://Data/party_data.json",
		"user://Data/party_resources.json",
		"user://Data/shadow_data.json",
		"user://Data/town_change_scene.json",
		"user://Data/town_invisible_wall_dialog.json",
		"user://Data/town_shop_dialog.json",
		"user://Data/toxic_furnance_dialog.json",
		"user://Data/wake_up_dialog.json",
		"user://Data/start_tutorial_battle_dialog.json",
		"user://Data/tutorial_dialog.json",
		"user://Data/after_tutorial_dialog.json",
		"user://Data/enter_cave_dialog.json"
	]
	
	var dir = DirAccess.open("user://")
	print(dir.dir_exists("Data"))
	if !dir.dir_exists("Data"):
		dir.make_dir_recursive("user://Data")
	
	for path in files_to_create:
		if !FileAccess.file_exists(path):
			var f = FileAccess.open(path, FileAccess.WRITE)
			var text = FileAccess.get_file_as_string(path.replace("user", "res"))
			var temp_data = JSON.parse_string(text)
			f.store_string(JSON.stringify(temp_data, "\t", false))
			f.close()
			FileAccess.file_exists(path)

func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/World.tscn")


func _on_exit_pressed():
	get_tree().quit()
