extends "res://scripts/label_hover.gd"

func _on_gui_input(event : InputEvent):
	if (event.is_pressed()):
		get_tree().quit()
