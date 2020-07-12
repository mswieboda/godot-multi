extends KinematicBody

var gravity = -9.8
var velocity = Vector3()

puppet var puppet_velocity = Vector3()

export var SPEED = 6
export var ACCELERATION = 3
export var DEACCELERATION = 5


func _physics_process(delta):
	movement(delta)


func enable_camera():
	$cam_target/camera.set_current(true)


func disable_camera():
	$cam_target/camera.set_current(false)
	pass


func set_color(color : Color):
	$mesh.get_surface_material(0).albedo_color = color


func movement(delta):
	var is_moving = false
	var horiz_velocity
	
	if is_network_master():
		var dir = Vector3()
		var camera_xform = $cam_target/camera.get_global_transform()
		
		if Input.is_action_pressed("move_forward"):
			dir += -camera_xform.basis.z
			is_moving = true
		if Input.is_action_pressed("move_backward"):
			dir += camera_xform.basis.z
			is_moving = true
		if Input.is_action_pressed("move_left"):
			dir += -camera_xform.basis.x
			is_moving = true
		if Input.is_action_pressed("move_right"):
			dir += camera_xform.basis.x
			is_moving = true
		
		dir.y = 0
		dir = dir.normalized()
		
		velocity.y += delta * gravity
		
		horiz_velocity = velocity
		horiz_velocity.y = 0
		
		var new_position = dir * SPEED
		var accel = DEACCELERATION
		
		if dir.dot(horiz_velocity) > 0:
			accel = ACCELERATION
		
		horiz_velocity = horiz_velocity.linear_interpolate(new_position, accel * delta)
		velocity.x = horiz_velocity.x
		velocity.z = horiz_velocity.z
		
		rset("puppet_velocity", velocity)
	else:
		velocity = puppet_velocity
	
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))

	if is_moving:
		var angle = atan2(horiz_velocity.x, horiz_velocity.z)
		var rotation = $mesh.get_rotation()
		rotation.y = angle
		$mesh.set_rotation(rotation)


func spawn(spawn_xform : Transform):
	var xform = get_global_transform()
	
	xform.origin.x = spawn_xform.origin.x
	xform.origin.z = spawn_xform.origin.z
	
	set_global_transform(xform)
