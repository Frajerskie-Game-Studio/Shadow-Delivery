extends Node

var deletedPointers = []
var after_fist_fight = false
var after_second_fight = false
var last_dialog_emit = false

signal start_dialog(path)
signal start_npc_dialog(npc_name, dialog_dict, dialog_npc, action)

func load_data(data):
	deletedPointers = data.deleted_pointers
	print(deletedPointers)
	for child in $Dialogs.get_children():
		if (child.Deletable and deletedPointers.find(child.name) != -1) or ((child.name == "Mine1Pointer" or child.name == "Mine2Pointer") and deletedPointers.find(child.name) != -1):
			if child.name == "Fight1Pointer":
				$Enemies1.visible = false
				after_fist_fight = true
			
			if child.name == "Mine1Pointer":
				after_fist_fight = false
				$Crystals1.visible = false
				
			if child.name == "Fight2Pointer":
				$Enemies2.visible = false
				after_second_fight = true
				
			if child.name == "Mine2Pointer":
				last_dialog_emit = true
				$Crystals2.visible = false
			child.queue_free()

func _ready():	
	get_parent().switch_zoom(1.2,1.2)
	#path, clickable, deletable, action, multi_state
	$Teammates/AnimationPlayer.play("idle")
	$Enemies1/AnimationPlayer.play("idle")
	$Enemies2/AnimationPlayer.play("idle")
	$Dialogs/EnterCave.load_data("user://Data/inside_cave_dialog.json", false, true, null, false)
	$Dialogs/Fight1Pointer.load_data("user://Data/first_fight_dialog.json", false, true, get_parent().start_fight, false)
	$Dialogs/Mine1Pointer.load_data("user://Data/first_mining_dialog.json", false, false, [mining_interaction, unshown_teammates],true)
	$Dialogs/Fight2Pointer.load_data("user://Data/second_fight_dialog.json", false, true, get_parent().start_fight, false)
	$Dialogs/Mine2Pointer.load_data("user://Data/second_mine.json", false, false, [shadow_interaction, shadow_interaction2], true)
	$Dialogs/LastDialog.load_data("user://Data/last_dialog.json", false, false, move_to_end_screen, true)
	
	


func _process(delta):
	if after_fist_fight:
		if has_node("Dialogs/Mine1Pointer"):
			$Teammates.visible = true
			$Dialogs/Mine1Pointer.emit_signal_via_code()
			
	if after_second_fight:
		if has_node("Dialogs/Mine2Pointer"):
			$Teammates.global_position = $TeammatesSecondPosition.global_position
			$Teammates.visible = true
			if $Dialogs/Mine2Pointer.currentDialogState == 1:
				$Teammates/AnimationPlayer.play("AfterExplosion")
				$Shadow/AnimationPlayer.play("idle")
				$Soundtrack.stream = load("res://Music/Dark_Cave_Soundtrack.wav")
				$Soundtrack.play()
				$Shadow.visible = true
				$Dialogs/Mine2Pointer.emit_signal_via_code()
				after_second_fight = false
			else:
				$Dialogs/Mine2Pointer.emit_signal_via_code()
				after_second_fight = false
	if last_dialog_emit:
		if has_node("Dialogs/LastDialog"):
			$Teammates.global_position = $TeammatesSecondPosition.global_position
			$Teammates.visible = true
			$Teammates/AnimationPlayer.play("AfterExplosion")
			$Shadow/AnimationPlayer.play("idle")
			$Shadow/AnimationPlayer.play("idle")
			$Shadow.visible = true
			$Soundtrack.stream = load("res://Music/Incident_Theme.wav")
			$Soundtrack.play()
			$Dialogs/LastDialog.emit_signal_via_code()
			last_dialog_emit = false

func mining_interaction():
	get_parent().play_switch_animation()
	$Crystals1.visible = false
	if has_node("Dialogs/Mine1Pointer"):
		$Dialogs/Mine1Pointer.emit_signal_via_code()
	
func shadow_interaction():
	$Crystals2.visible = false
	get_parent().delete_teammate("user://Data/michal_data.json", "res://Scenes/Actors/Michal.tscn")
	get_parent().delete_teammate("user://Data/krzychu_data.json", "res://Scenes/Actors/Krzychu.tscn")
	$Teammates/AnimationPlayer.play("AfterExplosion")
	$Shadow/AnimationPlayer.play("idle")
	get_parent().play_explosion_animation()
	$Explosion.play()
	$Shadow.visible = true
	
func shadow_interaction2():
	get_parent().add_teammate("user://Data/shadow_data.json", "res://Scenes/Actors/Shadow.tscn")
	get_parent().start_fight()
	deletedPointers.append($Dialogs/Mine2Pointer.name)
	$Dialogs/Mine2Pointer.queue_free()

func unshown_teammates():
	after_fist_fight = false
	get_parent().play_switch_animation()
	$Teammates.visible = false
	deletedPointers.append($Dialogs/Mine1Pointer.name)
	$Dialogs/Mine1Pointer.queue_free()

func _on_desk_dialog_start_dialog(path, d, action):
	start_dialog.emit(path, d, action)
	if deletedPointers.find(d.name) == -1 and d.Deletable:
		deletedPointers.append(d.name)

func _on_npc_show_dialog(npc_name, dialog_dict, dialog_npc, action):
	start_npc_dialog.emit(npc_name, dialog_dict, dialog_npc, action)


func _on_explosion_finished():
	$Dialogs/Mine2Pointer.emit_signal_via_code()
	$Soundtrack.stream = load("res://Music/Dark_Cave_Soundtrack.wav")
	$Soundtrack.play()


func move_to_end_screen():
	get_tree().change_scene_to_file("res://Scenes/EndScreen.tscn")
