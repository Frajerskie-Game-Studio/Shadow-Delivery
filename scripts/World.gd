extends Node

const DialogLoader = preload("res://scripts/DialogLoader.gd")
@onready var dialog_hud = preload("res://Scenes/HudCanvas.tscn")
@onready var d = preload("res://Scenes/Actors/Player.tscn")
@onready var battle_scene = preload("res://Scenes/BattleScene.tscn")
@onready var mikutroom = preload("res://Scenes/Levels/MikutRoom.tscn")
@onready var tutorial_battle_scene = preload("res://Scenes/BattleTutorial.tscn")


var CurrentLevel
var LevelsData
var CurrentLevelInstance
var Player

var current_dialog_npc
var in_dialog = false
var in_menu = false
var party_items
var data
var battlefield

var EnemiesArray = ["user://Data/darkslime_data.json", "user://Data/skeleton_data.json", "user://Data/shieldbug_data.json"]

signal itemDone

func _ready():
	print("I AM IN THE WORLD")
	play_switch_animation()
	var text = FileAccess.get_file_as_string("user://Data/party_data.json")
	var temp_data = JSON.parse_string(text)
	print(temp_data)
	data = temp_data
	party_items = temp_data["items"]
	$Menu.refresh_data()
	load_level()

func _process(delta):
	if !in_dialog and !$Player.in_battle:
		if Input.is_action_just_pressed("show_menu"):
			if $Menu.visible:
				$Player.unlock()
				$Menu.visible = false
				in_menu = false
			else:
				$Player.lock()
				$Menu.visible = true
				in_menu = true


func play_switch_animation():
	$CanvasLayer.visible = true
	$CanvasLayer/Control/BackgroundAnimation.play("show_level")


#showing dialog window (signal from NPC)
func _on_npc_show_dialog(npc_name, dialog_dict, dialog_npc, action):
	if !in_menu and !in_dialog:
		in_dialog = true
		$Player.lock()
		var this_dialog = dialog_hud.instantiate()
		self.add_child(this_dialog)
		this_dialog.load_data(npc_name, dialog_dict, action)
		#assiging NPC with whom player is talking
		if dialog_npc != null:
			current_dialog_npc = dialog_npc

func add_teammate(teammate, teammate_node):
	if !$Player.has_teammate(teammate):
		print("ADDING TEAMMATE")
		$Player.add_teammates(teammate, teammate_node)
		$Player.save_everything()
		$Player.load_everything()
		$Menu.refresh_data()
	else:
		print("HAS TEAMMATE")
	$Menu.refresh_data()
	
func delete_teammate(teammate, teammate_node):
	print("DELETE WORLD")
	print("AFTER IF")
	$Player.delete_teammate(teammate, teammate_node)
	$Player.save_everything()
	$Player.load_everything()
	$Menu.refresh_data()
func add_something(object, object_type):
	$Player.add_something(object, object_type)

#ending dialog
func end_dialog(action):
	#searching for npc wich player is talking to
	if current_dialog_npc != null:
		for child in get_children():
			if child == current_dialog_npc:
				child.end_dialog()
			elif child.get_class() == "Node":
				for childs_child in child.get_node("Dialogs").get_children():
					if childs_child == current_dialog_npc:
						childs_child.end_dialog()
	$Player.unlock()
	in_dialog = false
	if action != null:
		action.call()
	

func _on_canvas_layer_item_used(current_item, entity_name):
	#tu się kompletnie zesrałem na kod XDDDDDD
	#to ja posporzątam :)
	
	var text = FileAccess.get_file_as_string("user://Data/party_data.json")
	var temp_data = JSON.parse_string(text)
	data = temp_data
	for teammate in data.teammates:
		if teammate.contains(entity_name.to_lower()):
			if entity_name == "Mikut":
				entity_name = "Player"
			#mój programistyczny peak - nie wytłumaczę domyśl się sam lol
			var temp_teammate = load("res://Scenes/Actors/"+str(entity_name)+".tscn")
			var temp_instance = temp_teammate.instantiate()
			temp_instance.visible = false
			add_child(temp_instance)
			temp_instance.load_data()
			temp_instance.use_item(current_item)
			temp_instance.queue_free()
	
	var index = -1
	var i = 0
	for item in data.items:
		if(item.name == current_item.name):
			item.amount -= 1
		if(item.amount <= 0):
			index = i
		i += 1
	
	if(index != -1):
		data.items.remove_at(index)
	
	var file = FileAccess.open("user://Data/party_data.json", FileAccess.WRITE)
	
	file.store_string(JSON.stringify(data, "\t", false))
	file.close()
	itemDone.emit()
	for child in get_children():
		if child.has_node("CharacterBody2D"):
			child.load_data()


func _on_menu_save_eq(entity_name):
	for child in get_children():
		if child.has_node("CharacterBody2D"):
			child.load_data()


func _on_dialog_pointer_start_dialog(path, dialog_pointer, action):
	if !in_menu:
		var d = DialogLoader.new()
		d.load_data(path, action)
		d.showDialog.connect(_on_npc_show_dialog)
		d.start_dialog()
		if dialog_pointer.Deletable:
			dialog_pointer.queue_free()
		else:
			current_dialog_npc = dialog_pointer
	
func start_fight():
	for c in get_children():
		if c.get_class() != "Node":
			c.visible = false
		else:
			for in_c in c.get_children():
				if in_c.get_class() != "AudioStreamPlayer":
					in_c.visible = false
				else:
					in_c.playing = false
	battlefield= battle_scene.instantiate()
	battlefield.end_whole_battle.connect(end_battle)
	$Player.lock()
	$Player.in_battle = true
	for c in get_children():
		if c.get_class() == "Node2D":
			c.save_data()
			c.save_items()
			c.save_resources()
	add_child(battlefield)
	$Player.get_node("PlayerBody").get_node("Camera2D").enabled = false
	var random_enemy = RandomNumberGenerator.new()
	var enemy_array = []
	var random_enemy_number = random_enemy.randi_range(2, 3)
	for i in range(random_enemy_number):
		enemy_array.append(EnemiesArray[random_enemy.randi_range(0, len(EnemiesArray) - 1)])
	battlefield.load_entities($Player.Party_Data.teammates_nodes, enemy_array)
	
func start_tutorial_fight():
	in_dialog = false
	for c in get_children():
		if c.get_class() != "Node":
			c.visible = false
		else:
			for in_c in c.get_children():
				if in_c.get_class() != "AudioStreamPlayer":
					in_c.visible = false
				else:
					in_c.playing = false
	battlefield= tutorial_battle_scene.instantiate()
	battlefield.start_dialog.connect(_on_dialog_pointer_start_dialog)
	battlefield.end_whole_battle.connect(end_battle)
	$Player.lock()
	$Player.in_battle = true
	for c in get_children():
		if c.get_class() == "Node2D":
			c.save_data()
			c.save_items()
			c.save_resources()
	add_child(battlefield)
	$Player.get_node("PlayerBody").get_node("Camera2D").enabled = false
	battlefield.load_entities($Player.Party_Data.teammates_nodes, ["user://Data/tutorial_enemy.json", "user://Data/tutorial_enemy.json"])
	
func add_object_to_player(object, object_type):
	print("ADDING OBJECT")
	$Player.add_something(object, object_type)
	$Player.save_everything()
	$Player.load_everything()
	$Menu.refresh_data()
	
func end_battle():
	battlefield.queue_free()
	for c in get_children():
		if c.get_class() != "CanvasLayer" and c.get_class() != "Node":
			c.visible = true
			if c.get_class() == "Node2D":
				c.load_data()
				c.load_items()
				c.load_res()
		elif c.get_class() == "Node":
			for in_c in c.get_children():
				if in_c.get_class() != "AudioStreamPlayer":
					in_c.visible = true
				else:
					in_c.playing = true
	save_level_data(false)
	load_level()
	if $Player.in_tutorial:
		$Player.in_tutorial = false
	$Player.unlock()
	$Player.get_node("PlayerBody").get_node("Camera2D").enabled = true
	$Player.in_battle = false
	$Menu.refresh_data()

func load_level():
	var level_text = FileAccess.get_file_as_string("user://Data/level_saves.json")
	var temp_level_data = JSON.parse_string(level_text)
	if CurrentLevelInstance != null:
		CurrentLevelInstance.queue_free()
	CurrentLevel = temp_level_data.currentLevel
	LevelsData = temp_level_data.levels_data
	CurrentLevelInstance = load(LevelsData[CurrentLevel].path).instantiate()
	
	add_child(CurrentLevelInstance)
	move_child(CurrentLevelInstance, 0)
	
	CurrentLevelInstance.load_data(LevelsData[CurrentLevel])
	CurrentLevelInstance.start_dialog.connect(_on_dialog_pointer_start_dialog)
	CurrentLevelInstance.start_npc_dialog.connect(_on_npc_show_dialog)
	
	$Player.get_node("PlayerBody").position = Vector2(LevelsData[CurrentLevel].player_position[0],LevelsData[CurrentLevel].player_position[1])
	$Menu.refresh_data()



func save_level_data(switching_levels):
	var file = FileAccess.open("user://Data/level_saves.json", FileAccess.WRITE)
	
	LevelsData[CurrentLevel].deleted_pointers = CurrentLevelInstance.deletedPointers
	LevelsData[CurrentLevel].player_position = [$Player.get_node("PlayerBody").position.x, $Player.get_node("PlayerBody").position.y]
	
	if switching_levels:
		if len(LevelsData) - 1 > CurrentLevel: 
			CurrentLevel += 1
	
	var temp_data = {
		"currentLevel": CurrentLevel,
		"levels_data": LevelsData
	}
	file.store_string(JSON.stringify(temp_data, "\t", false))
	file.close()
	
func switch_level():
	save_level_data(true)
	load_level()
	$CanvasLayer.visible = true
	$CanvasLayer/Control/BackgroundAnimation.play("show_level")
	
func switch_zoom(x, y):
	$Player/PlayerBody/Camera2D.zoom = Vector2(x,y)

func play_explosion_animation():
	$CanvasLayer.visible = true
	$CanvasLayer/Control/BackgroundAnimation.play("hide_level")

func _on_background_animation_animation_finished(anim_name):
	$CanvasLayer.visible = false


func _on_menu_crafted_something():
	$Player.load_everything()
