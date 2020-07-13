extends "res://scripts/label_hover.gd"

onready var popup = get_node("/root/menu/popup")


func _on_gui_input(event : InputEvent):
	if (event.is_pressed()):
		var lobbies = get_parent().get_parent().get_node("lobbies")
		get_parent().hide()
		lobbies.show()
		lobbies.load_lobbies()
		reset_hover()
