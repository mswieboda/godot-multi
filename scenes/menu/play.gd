extends "res://scenes/menu/menu.gd"

onready var main = get_parent().get_node("main")
onready var single = get_parent().get_node("single")
onready var multi = get_parent().get_node("multi")

func _on_single_gui_input(event : InputEvent):
	is_pressed_go_to(event, single)

func _on_multi_gui_input(event : InputEvent):
	is_pressed_go_to(event, multi)

func _on_back_gui_input(event : InputEvent):
	is_pressed_go_to(event, main)
