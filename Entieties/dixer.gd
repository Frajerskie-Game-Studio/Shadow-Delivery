extends Node

@onready var dialog_hud = preload("res://Entieties/HudCanvas.tscn")

var current_dialog_npc

func _ready():
	pass

func _process(delta):
	pass

#showing dialog window (signal from NPC)
func _on_npc_show_dialog(npc_name, dialog_dict, dialog_npc):
	$Player.lock()
	var this_dialog = dialog_hud.instantiate()
	self.add_child(this_dialog)
	this_dialog.load_data(npc_name, dialog_dict)
	#assiging NPC with whom player is talking
	current_dialog_npc = dialog_npc

#ending dialog
func end_dialog():
	#searching for npc wich player is talking to
	for child in get_children():
		if child == current_dialog_npc:
			child.end_dialog()
	$Player.unlock()
	
