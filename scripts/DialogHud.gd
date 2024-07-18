extends Control


@onready var writetext = false
var dialog_text

signal next_line

func _ready():
	pass

#loading dialog line
func load_data(npc_name, npc_text):
	dialog_text = npc_text
	$MarginContainer/HBoxContainer/Panel/VBoxContainer/MarginContainer/Name.text = npc_name
	$MarginContainer/HBoxContainer/Panel/VBoxContainer/MarginContainer2/RichTextLabel.text = dialog_text
	writetext = true


func _process(delta):
	#animation of dialog
	if writetext:
		if $MarginContainer/HBoxContainer/Panel/VBoxContainer/MarginContainer2/RichTextLabel.visible_characters < dialog_text.length():
			$MarginContainer/HBoxContainer/Panel/VBoxContainer/MarginContainer2/RichTextLabel.visible_characters += 1
		else:
			$MarginContainer/HBoxContainer/Panel/VBoxContainer/MarginContainer2/RichTextLabel.visible_characters = -1
			writetext = false
	#emmiting signal for showing next line of dialog to HudCanvas
	elif Input.is_action_just_pressed("mouse_click"):
		next_line.emit()
