extends "res://scripts/label_hover.gd"

onready var popup = get_node("/root/menu/popup")

func _on_gui_input(event : InputEvent):
	if (event.is_pressed()):
		popup.show_create()
		reset_hover()
