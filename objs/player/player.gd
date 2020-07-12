extends Spatial


func _ready():
	pass


func enable_camera():
	$camera.set_current(true)


func disable_camera():
	$camera.set_current(false)


func set_color(color : Color):
	$mesh.get_surface_material(0).albedo_color = color
