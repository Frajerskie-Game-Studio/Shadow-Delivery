extends Node

@onready var dialog_hud = preload("res://Entieties/HudCanvas.tscn")

var current_dialog_npc

func _ready():
	pass

func _process(delta):
	pass


func _on_npc_show_dialog(npc_name, dialog_dict, dialog_npc):
	var this_dialog = dialog_hud.instantiate()
	self.add_child(this_dialog)
	this_dialog.load_data(npc_name, dialog_dict)
	current_dialog_npc = dialog_npc
	
func end_dialog():
	for child in get_children():
		if child == current_dialog_npc:
			child.end_dialog()
	
