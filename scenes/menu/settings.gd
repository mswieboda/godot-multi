extends "res://scenes/menu/menu.gd"

onready var main = get_parent().get_node("main")


func _ready():
	$fullscreen/toggle.pressed = OS.window_fullscreen


func _on_back_gui_input(event : InputEvent):
	is_pressed_go_to(event, main)


func _on_toggle_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
