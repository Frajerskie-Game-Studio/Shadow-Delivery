extends StaticBody2D

var npc_name
var current_dialog_position
var npc_data
var can_move = false

var Frames
var SpriteSheetPath
var FilePath
var Action
var Deletable
#signal for showing dialog
signal showDialog(npc_name, dialog_dict, dialog_npc, action)

var ableToTalk = false
#variable blocking for showing another dialog window if one is showed
var block = false
var dialogStates

func load_data(path_to_file, path_to_spritesheet, frames, action, deletable):
	#getting json data and assigning it to npc_data
	var text = FileAccess.get_file_as_string(path_to_file)
	npc_data = JSON.parse_string(text)
	
	
	npc_name = npc_data["name"]
	#array of dialog states (look at npc_test.json)
	dialogStates = npc_data["dialogStates"]
	#position of dialog state
	current_dialog_position = npc_data["currentDialogState"]
	
	FilePath = path_to_file
	SpriteSheetPath = path_to_spritesheet
	Frames = frames
	Action = action
	Deletable = deletable
	
	$Sprite2D.texture = load(SpriteSheetPath)
	$Sprite2D.hframes = Frames
	$AnimationPlayer.play("left_down")

#saving data to json file
func writeToJson():
	var file = FileAccess.open(FilePath, FileAccess.WRITE)
	file.store_string(JSON.stringify(npc_data, "\t"))
	file.close()
	

func _ready():
	pass
	
func _process(delta):
	if ableToTalk and !block:
		if Input.is_action_just_pressed("mouse_click"):
			print("Begin dialog...")
			block = true
			#emmiting signal for showing dialog windows
			if typeof(Action) == TYPE_ARRAY:
				showDialog.emit(npc_name, npc_data[dialogStates[current_dialog_position]], self, Action[current_dialog_position])
			else:
				showDialog.emit(npc_name, npc_data[dialogStates[current_dialog_position]], self, Action)
			#changing dialog state if possible
			if current_dialog_position < len(dialogStates) - 1:
				current_dialog_position += 1
				npc_data["currentDialogState"] = current_dialog_position
			#saving data
			writeToJson()
			
func end_dialog():
	block = false

#allowing player to talk to NPC when mouse is on NPC
func _on_mouse_entered():
	if !block:
		ableToTalk = true
		$FaggotIndicator.visible = true
		$FaggotIndicator.play()


func _on_mouse_exited():
	if !block:
		ableToTalk = false
		$FaggotIndicator.visible = false
		$FaggotIndicator.stop()
