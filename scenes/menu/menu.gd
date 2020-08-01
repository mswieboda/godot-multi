extends VBoxContainer

func is_pressed_go_to(event : InputEvent, menu : Node):
	if (event.is_pressed()):
		go_to(menu)
		return true
	return false

func go_to(menu : Node):
	hide()
	menu.show()
