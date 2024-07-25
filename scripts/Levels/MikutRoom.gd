extends Node

signal start_dialog(path)
signal start_npc_dialog(npc_name, dialog_dict, dialog_npc, action)

func _ready():
	#var d = DialogLoader.new()
	#d.load_data("res://Data/npc_test.json")
	#d.showDialog.connect(_on_npc_show_dialog)
	#d.start_dialog()
	
	$DeskDialog.load_data("res://Data/desk.json", true, false, null, true)
	$BedDialog.load_data("res://Data/wake_up_dialog.json", false, true, null, false)
	$DoorDialog.load_data("res://Data/door_dialog.json", true, false, null, false)


func _process(delta):
	pass


func _on_desk_dialog_start_dialog(path, d, action):
	start_dialog.emit(path, d, action)

func _on_npc_show_dialog(npc_name, dialog_dict, dialog_npc, action):
	start_npc_dialog.emit(npc_name, dialog_dict, dialog_npc, action)
