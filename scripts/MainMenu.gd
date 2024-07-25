extends Node


func _ready():
	pass

func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/World.tscn")


func _on_exit_pressed():
	get_tree().quit()
