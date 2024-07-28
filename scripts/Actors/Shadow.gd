extends "Lucjan.gd"

func _init():
	#zmień plik
	character_file_path = "res://Data/shadow_data.json"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "hide_range":
		animationState.travel("melee_idle")
	elif anim_name == "show_range":
		animationState.travel("range_idle")
	elif anim_name == "melee_attack":
		can_be_attacked = true
		animationState.travel("melee_idle")
	elif anim_name == "range_attack":
		can_be_attacked = true
		animationState.travel("melee_idle")
	elif anim_name == "get_damage":
		if current_style == "melee":
			animationState.travel("melee_idle")
		else:
			if waiting:
				animationState.travel("melee_idle")
			else:
				animationState.travel("range_idle")
	elif anim_name == "use_item":
		if current_style == "melee":
			animationState.travel("melee_idle")
		else:
			animationState.travel("range_idle")
