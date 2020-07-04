extends Label

export var default_color : Color = Color.white;
export var hover_color : Color = Color.green;

func _on_join_mouse_entered():
	set("custom_colors/font_color", hover_color)

func _on_join_mouse_exited():
	set("custom_colors/font_color", default_color)
