extends KinematicBody

var is_moving = false
var velocity = Vector3()

const GRAVITY = -9.8
const MOUSE_SENSITIVITY = 0.003
const MAX_VERTICAL_LOOK = 1.25

export var SPEED = 6
export var ACCELERATION = 3
export var DEACCELERATION = 5


func puts(output):
	print("Player#" + get_name() + ": " + str(output))


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	movement(delta)


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		$cam_pivot.rotate_x(event.relative.y * MOUSE_SENSITIVITY)
		$cam_pivot.rotation.x = clamp($cam_pivot.rotation.x, -MAX_VERTICAL_LOOK, MAX_VERTICAL_LOOK)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func enable_camera():
	$cam_pivot/camera.set_current(true)


func disable_camera():
	$cam_pivot/camera.set_current(false)
	pass


func set_color(color : Color):
	$body/mesh.material_override = SpatialMaterial.new()
	$body/mesh.material_override.albedo_color = color


func movement(delta):
	if is_network_master():
		var dir = Vector3()
		var camera_xform = $cam_pivot/camera.get_global_transform()
		
		if Input.is_action_pressed("move_forward"):
			dir += -$cam_pivot/camera.global_transform.basis.z
		if Input.is_action_pressed("move_backward"):
			dir += $cam_pivot/camera.global_transform.basis.z
		if Input.is_action_pressed("strafe_left"):
			dir += -$cam_pivot/camera.global_transform.basis.x
		if Input.is_action_pressed("strafe_right"):
			dir += $cam_pivot/camera.global_transform.basis.x
		
		dir.y = 0
		
		if not is_on_floor():
			velocity.y += delta * GRAVITY
		
		var horiz_velocity = velocity
		horiz_velocity.y = 0
		
		var new_position = dir * SPEED
		var accel = DEACCELERATION
		
		if dir.dot(horiz_velocity) > 0:
			accel = ACCELERATION
		
		horiz_velocity = horiz_velocity.linear_interpolate(new_position, accel * delta)
		velocity.x = horiz_velocity.x
		velocity.z = horiz_velocity.z
		
		rpc_unreliable("peer_movement", is_moving, velocity)
	
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))


remote func peer_movement(peer_is_moving, peer_velocity):
	is_moving = peer_is_moving
	velocity = peer_velocity


func spawn(spawn_xform : Transform):
	var xform = get_global_transform()
	
	xform.origin.x = spawn_xform.origin.x
	xform.origin.z = spawn_xform.origin.z
	
	set_global_transform(xform)
