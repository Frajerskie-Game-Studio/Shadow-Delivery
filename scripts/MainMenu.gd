extends Node


func _ready():
	print("Is user ffile system persistent: " + str(OS.is_userfs_persistent()))
	
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("Data"):
		dir.make_dir("Data")


func _process(delta):
	pass


func get_initial_data_files():
	var initial_data_dir = DirAccess.open("res://Data")
	return initial_data_dir.get_files()


func get_user_data_files():
	var user_data_dir = DirAccess.open("user://Data")
	return user_data_dir.get_files()


func create_user_data_file(file_name):
	var text = FileAccess.get_file_as_string(file_name.replace("user", "res"))
	var temp_data = JSON.parse_string(text)
	
	var new_file = FileAccess.open(file_name, FileAccess.WRITE)
	new_file.store_string(JSON.stringify(temp_data, "\t", false))
	new_file.close()


func _on_new_game_button_pressed():
	var files_to_create = get_user_data_files()
	
	$Control/Modal/NewGameConfirmDialog.get_ok_button().pressed.connect(new_game_confirmed.bind(files_to_create))
	$Control/Modal/NewGameConfirmDialog.get_cancel_button().pressed.connect(new_game_cancelled)
	
	if(files_to_create.size() > 0):
		$Control/Modal.visible = true
		$Control/Modal/NewGameConfirmDialog.visible = true
	else:
		new_game_confirmed(get_initial_data_files())


func new_game_confirmed(files_to_create):
	for path in files_to_create:
		var user_file_path = "user://Data/" + path
		create_user_data_file(user_file_path)
	
	get_tree().change_scene_to_file("res://Scenes/World.tscn")


func new_game_cancelled():
	$Control/Modal.visible = false
	$Control/Modal/NewGameConfirmDialog.visible = false


func _on_continue_button_pressed():
	var files_to_check = get_initial_data_files()
	
	for path in files_to_check:
		var user_file_path = "user://Data/" + path
		if !FileAccess.file_exists(user_file_path):
			create_user_data_file(user_file_path)
	
	get_tree().change_scene_to_file("res://Scenes/World.tscn")


func _on_exit_pressed():
	get_tree().quit()
