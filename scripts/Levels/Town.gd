extends Node


var deletedPointers = []

signal start_dialog(path)
signal start_npc_dialog(npc_name, dialog_dict, dialog_npc, action)

func load_data(data):
	deletedPointers = data.deleted_pointers
	for child in $Dialogs.get_children():
		if child.Deletable and deletedPointers.find(child.name) != -1:
			child.queue_free()

func _ready():
	get_parent().switch_zoom(1.8,1.8)
	$Dialogs/OutsidePlayerDoor.load_data("user://Data/outside_door_dialog.json", true, false, null, true)
	$Dialogs/InvisibleWall.load_data("user://Data/town_invisible_wall_dialog.json", false, false, null, false)
	$Dialogs/ShopDoor.load_data("user://Data/town_shop_dialog.json", true, false, null, true)
	$Dialogs/LevelChanger.load_data("user://Data/town_change_scene.json", false, false, get_parent().switch_level, false)

func _process(delta):
	pass


func _on_desk_dialog_start_dialog(path, d, action):
	start_dialog.emit(path, d, action)
	if deletedPointers.find(d.name) == -1 and d.Deletable:
		deletedPointers.append(d.name)

func _on_npc_show_dialog(npc_name, dialog_dict, dialog_npc, action):
	start_npc_dialog.emit(npc_name, dialog_dict, dialog_npc, action)
