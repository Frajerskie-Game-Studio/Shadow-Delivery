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
	$Dialogs/DeskDialog.load_data("res://Data/desk.json", true, false, null, true)
	$Dialogs/BedDialog.load_data("res://Data/wake_up_dialog.json", false, true, null, false)
	$Dialogs/DoorDialog.load_data("res://Data/door_dialog.json", true, false, get_parent().switch_level, false)

func _process(delta):
	pass


func _on_desk_dialog_start_dialog(path, d, action):
	start_dialog.emit(path, d, action)
	if deletedPointers.find(d.name) == -1:
		deletedPointers.append(d.name)

func _on_npc_show_dialog(npc_name, dialog_dict, dialog_npc, action):
	start_npc_dialog.emit(npc_name, dialog_dict, dialog_npc, action)
