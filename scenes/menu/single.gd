extends "res://scenes/menu/menu.gd"

onready var play = get_parent().get_node("play")

func _on_back_gui_input(event : InputEvent):
	is_pressed_go_to(event, play)

func _on_start_gui_input(event):
	if event.is_pressed():
		var single = preload("res://scenes/single/single.tscn").instance()
		Scene.change(single)
		single.start({color = Color.green})
