extends "res://scripts/label_hover.gd"

func _on_gui_input(event : InputEvent):
	if (event.is_pressed()):
		var lobby = get_parent()
		lobby.leave_lobby()
		reset_hover()
