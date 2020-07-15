tool
extends Label

export var color : Color = Color.white setget set_color
export var hover_color : Color = Color.green setget set_hover_color
export var font_size : int = 16 setget set_font_size
export var hoverable : bool = true setget set_hoverable

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


func _on_gui_input(event):
	if event.is_pressed() and hoverable:
		change_color(color)


func _on_mouse_entered():
	if hoverable:
		change_color(hover_color)


func _on_mouse_exited():
	if hoverable:
		change_color(color)
