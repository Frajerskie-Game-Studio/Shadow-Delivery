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
	var resource = {
		"skeleton_powder": {
		"ammount": 45,
		"texture": ""
	}}
	$ConveyorBelt/AnimationPlayer.play("Convbelt")
	$Dialogs/NPC.load_data("user://Data/factory_lucjan_dialog.json", "user://Graphics/Lucjan/LucjanSpriteSheet.png", 92, [get_parent().add_object_to_player.bind(resource, "resource"), dix], false)
	#path, clickable, deletable, action, multi_state
	$Dialogs/HealthFurnanceDialogPointer.load_data("user://Data/health_furnance_dialog.json", true, false, null, false)
	$Dialogs/ToxicFurnancePointer.load_data("user://Data/toxic_furnance_dialog.json", true, false, null, false)
	$PartyMembers/AnimationPlayer.play("Idle")
	$Dialogs/MasterDialog.load_data("user://Data/factory_master_dialog.json", false, true, get_parent().switch_level, false)

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
	$Master.visible = true
	$Dialogs/MasterDialog.visible = true
	$Dialogs/MasterDialog.monitoring = true
	$Dialogs/MasterDialog.emit_signal_via_code()
	#tutaj będzie dodanie potek leczących
	#var item = {}
	#get_parent().add_object_to_player()

