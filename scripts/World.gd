extends Node

const DialogLoader = preload("res://scripts/DialogLoader.gd")
@onready var dialog_hud = preload("res://Scenes/HudCanvas.tscn")
@onready var d = preload("res://Scenes/Actors/Player.tscn")

var current_dialog_npc
var in_dialog = false
var party_items
var data

signal itemDone

func _ready():
	var text = FileAccess.get_file_as_string("res://Data/party_data.json")
	var temp_data = JSON.parse_string(text)
	data = temp_data
	party_items = temp_data["items"]
	#var d = DialogLoader.new()
	#d.load_data("res://Data/npc_test.json")
	#d.showDialog.connect(_on_npc_show_dialog)
	#d.start_dialog()
	#
	$Node.load_entities(["res://Scenes/Actors/Player.tscn", "res://Scenes/Actors/Lucjan.tscn"], ["res://Data/darkslime_data.json", "res://Data/darkslime_data.json"])

func _process(delta):
	if !in_dialog:
		if Input.is_action_just_pressed("show_menu"):
			if $Menu.visible:
				$Player.unlock()
				$Menu.visible = false
			else:
				$Player.lock()
				$Menu.visible = true

#showing dialog window (signal from NPC)
func _on_npc_show_dialog(npc_name, dialog_dict, dialog_npc):
	print("DIAKIG")
	in_dialog = true
	$Player.lock()
	var this_dialog = dialog_hud.instantiate()
	self.add_child(this_dialog)
	this_dialog.load_data(npc_name, dialog_dict)
	#assiging NPC with whom player is talking
	if dialog_npc != null:
		current_dialog_npc = dialog_npc
	
	
#func _on_dialog_pointer_show(dialog_pointer):
	#in_dialog = true
	#$Player.lock()
	#current_dialog_npc = dialog_pointer
	#current_dialog_npc.load_data()
	
#ending dialog
func end_dialog():
	#searching for npc wich player is talking to
	if current_dialog_npc != null:
		for child in get_children():
			if child == current_dialog_npc:
				child.end_dialog()
	$Player.unlock()
	in_dialog = false
	


func _on_canvas_layer_item_used(item_name, entity_name):
	var item
	
	for i in party_items:
		if i == item_name:
			item = party_items[i]
	print(item)
	#tu się kompletnie zesrałem na kod XDDDDDD
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
			if len(item) == 5:
				temp_instance.use_item({"dmg": item[1], "heal": item[2], "key": item_name, "effect": item[4]})
			else:
				temp_instance.use_item({"dmg": item[1], "heal": item[2], "key": item_name})
			#temp_instance.use_item({item})
			temp_instance.queue_free()
			
	
	data.items[item_name][3] -= 1
	if data.items[item_name][3] <= 0:
		data.items.erase(item_name)
	
	var file = FileAccess.open("res://Data/party_data.json", FileAccess.WRITE)
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	itemDone.emit()
	for child in get_children():
		if child.has_node("CharacterBody2D"):
			child.load_data()

func _on_menu_save_eq(entity_name):
	for child in get_children():
		if child.has_node("CharacterBody2D"):
			child.load_data()
