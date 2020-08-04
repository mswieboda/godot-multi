extends MeshInstance


func _ready():
	# Clear the viewport.
	$viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)

	# Let two frames pass to make sure the vieport is captured.
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	get_material_override().albedo_texture = $viewport.get_texture()


func start():
	pass


func stop():
	pass
