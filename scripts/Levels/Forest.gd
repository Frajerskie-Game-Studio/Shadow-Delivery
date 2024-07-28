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
	get_parent().switch_zoom(2,2)

func _process(delta):
	pass


func _on_desk_dialog_start_dialog(path, d, action):
	start_dialog.emit(path, d, action)
	if deletedPointers.find(d.name) == -1 and d.Deletable:
		deletedPointers.append(d.name)

func _on_npc_show_dialog(npc_name, dialog_dict, dialog_npc, action):
	start_npc_dialog.emit(npc_name, dialog_dict, dialog_npc, action)
	
	
func dix():
	get_parent().play_switch_animation()
