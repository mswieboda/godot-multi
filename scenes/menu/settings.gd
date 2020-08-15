extends "res://scenes/menu/menu.gd"

onready var main = get_parent().get_node("main")

func _on_back_gui_input(event : InputEvent):
	is_pressed_go_to(event, main)
