extends Node

var deletedPointers = []
var emit_add_party_signal = false

signal start_dialog(path)
signal start_npc_dialog(npc_name, dialog_dict, dialog_npc, action)

func load_data(data):
	deletedPointers = data.deleted_pointers
	print(deletedPointers)
	for child in $Dialogs.get_children():
		if child.Deletable and deletedPointers.find(child.name) != -1:
			child.queue_free()

func _ready():	
	get_parent().switch_zoom(2,2)
	#path, clickable, deletable, action, multi_state
	$Dialogs/TutorialFight.load_data("user://Data/start_tutorial_battle_dialog.json", false, true, get_parent().start_tutorial_fight, false)
	$Dialogs/EnterCave.load_data("res://Data/inside_cave_dialog.json", false, true, null, false)
	


func _process(delta):
	pass

func _on_desk_dialog_start_dialog(path, d, action):
	start_dialog.emit(path, d, action)
	if deletedPointers.find(d.name) == -1 and d.Deletable:
		deletedPointers.append(d.name)

func _on_npc_show_dialog(npc_name, dialog_dict, dialog_npc, action):
	start_npc_dialog.emit(npc_name, dialog_dict, dialog_npc, action)
