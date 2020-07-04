extends "res://scripts/label_hover.gd"

func _on_join_gui_input(event : InputEvent):
	if (event.is_pressed()):
		print_debug("create!")
	
