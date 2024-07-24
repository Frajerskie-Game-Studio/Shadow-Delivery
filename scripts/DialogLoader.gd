extends Node

var currentDialogState
var dialogStates
var dialog_data
var action

signal showDialog(npc_name, dialog_dict, dialog_npc, action)

func load_data(path, a):
	var text = FileAccess.get_file_as_string(path)
	dialog_data = JSON.parse_string(text)
	currentDialogState = dialog_data.currentDialogState
	dialogStates = dialog_data.dialogStates
	action = a
	
func start_dialog():
	showDialog.emit(dialog_data.name, dialog_data[dialogStates[currentDialogState]], null, action)
	

func _ready():
	pass

func _process(delta):
	pass
