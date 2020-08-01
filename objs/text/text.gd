tool
extends Label

export var color : Color = Color.white setget set_color
export var hover_color : Color = Color.green setget set_hover_color
export var font_size : int = 16 setget set_font_size
export var hoverable : bool = true setget set_hoverable

signal gui_action

var hovered = false

func _ready():
	set_color(color)
	set_font_size(font_size)


func set_color(new_color : Color):
	color = new_color
	change_color(color)


func set_hover_color(new_color : Color):
	hover_color = new_color


func set_hoverable(is_hoverable):
	hoverable = is_hoverable
	change_cursor(CURSOR_POINTING_HAND if hoverable else CURSOR_ARROW)


func set_font_size(size):
	if size != font_size:
		font_size = size
		var dfont = get_font("font").duplicate(true)
		dfont.size = font_size
		add_font_override("font", dfont)


func change_color(new_color : Color):
	set("custom_colors/font_color", new_color)


func change_cursor(new_cursor):
	set("mouse_default_cursor_shape", new_cursor)


func hover():
	if !hoverable or hovered:
		return
	change_color(hover_color)
	hovered = true


func unhover():
	if !hoverable or !hovered:
		return
	change_color(color)
	hovered = false


func _on_gui_input(event : InputEvent):
	if event.is_action_released("ui_accept"):
		emit_signal("gui_action")
		pass
	if event.is_pressed():
		unhover()
	elif event is InputEventMouseMotion:
		hover()


func _on_mouse_exited():
	unhover()



