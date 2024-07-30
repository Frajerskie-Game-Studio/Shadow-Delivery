extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/AnimationPlayer.play("ShowAnimation")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_leave_pressed():
	get_tree().quit()
