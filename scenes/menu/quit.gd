extends "res://objs/menu_label/menu_label.gd"

func _on_gui_input(event : InputEvent):
	if (event.is_pressed()):
		get_tree().quit()
