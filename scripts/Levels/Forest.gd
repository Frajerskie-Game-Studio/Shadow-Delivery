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
			print(child.name)
			if child.name == "TutorialFight":
				emit_add_party_signal = true
			child.queue_free()

func _ready():	
	get_parent().switch_zoom(2,2)
	#path, clickable, deletable, action, multi_state
	$Dialogs/TutorialFight.load_data("user://Data/start_tutorial_battle_dialog.json", false, true, get_parent().start_tutorial_fight, false)
	$Dialogs/AddPartyDialog.load_data("res://Data/after_tutorial_dialog.json", false, false, dixer, false)


func _process(delta):
	if emit_add_party_signal:
		$Dialogs/AddPartyDialog.emit_signal_via_code()
		emit_add_party_signal = false

func _on_desk_dialog_start_dialog(path, d, action):
	print(str(d) + " I AM EMMITING SHITHEAD")
	start_dialog.emit(path, d, action)
	if deletedPointers.find(d.name) == -1 and d.Deletable:
		deletedPointers.append(d.name)

func _on_npc_show_dialog(npc_name, dialog_dict, dialog_npc, action):
	start_npc_dialog.emit(npc_name, dialog_dict, dialog_npc, action)
	
func toggle_dialogs(name):
	if name == "add_party":
		$Dialogs/AddPartyDialog.monitoring = true

func dixer():
	get_parent().play_switch_animation()
	get_parent().add_teammate("user://Data/lucjan_data.json", "res://Scenes/Actors/Lucjan.tscn")
	get_parent().add_teammate("user://Data/michal_data.json", "res://Scenes/Actors/Michal.tscn")
	get_parent().add_teammate("user://Data/krzychu_data.json", "res://Scenes/Actors/Krzychu.tscn")
	$PartyMembers.visible = false
