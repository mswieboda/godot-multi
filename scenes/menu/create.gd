extends "res://scripts/label_hover.gd"

func _on_gui_input(event : InputEvent):
	if (event.is_pressed()):
		var menu = get_parent()
		var main = menu.get_parent()
		var lobby = main.get_node("lobby")
		
		lobby.create_server("matt")
		
		reset_hover()
