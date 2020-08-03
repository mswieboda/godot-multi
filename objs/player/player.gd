extends KinematicBody

var is_moving = false
var velocity = Vector3()

const GRAVITY = -9.8 * 9.8
const MOUSE_SENSITIVITY = 0.003
const MAX_VERTICAL_LOOK = 1.25

export var JUMP_HEIGHT = 33
export var SPEED = 6
export var ACCELERATION = 3
export var DEACCELERATION = 5

export var PLAYABLE = true


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	movement(delta)


func _unhandled_input(event):
	if !is_playable():
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		$cam_pivot.rotate_x(event.relative.y * MOUSE_SENSITIVITY)
		$cam_pivot.rotation.x = clamp($cam_pivot.rotation.x, -MAX_VERTICAL_LOOK, MAX_VERTICAL_LOOK)
	
	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.button_index == BUTTON_WHEEL_UP:
			$cam_pivot/camera.fov /= 1.5
		elif event.button_index == BUTTON_WHEEL_DOWN:
			$cam_pivot/camera.fov *= 1.5
	
	if event.is_action_pressed("fire"):
		$cam_pivot/pistol.fire()


func _input(event):
	if !is_playable():
		return
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func is_playable() -> bool:
	if PLAYABLE:
		if get_tree().has_network_peer():
			return is_network_master()
	return PLAYABLE


func hit_texture():
	return false


func hit(weapon : Node, position : Vector3, normal : Vector3):
	print(get_name(), " hit by ", weapon.get_name(), " with ", weapon.damage())
	var fx = preload("res://objs/bullet_hit_fx/bullet_hit_fx.tscn").instance()
	fx.emitting = true
	
	add_child(fx)
	
	fx.global_transform.origin = position
	fx.global_transform.basis = Global.perpendicular_basis_from_normal(normal)
	fx.global_transform.origin += normal * Global.HEIGHT_LAYERING_RATIO


func enable_camera():
	$cam_pivot/camera.set_current(true)


func disable_camera():
	$cam_pivot/camera.set_current(false)
	pass


func set_color(color : Color):
	$body/mesh.material_override = SpatialMaterial.new()
	$body/mesh.material_override.albedo_color = color


func movement(delta):
	if !is_playable():
		velocity = move_and_slide(velocity, Vector3(0, 1, 0))
		return
	
	var dir = Vector3()
	var camera_xform_basis = $cam_pivot/camera.get_global_transform().basis
	
	if Input.is_action_pressed("move_forward"):
		dir += -camera_xform_basis.z
	if Input.is_action_pressed("move_backward"):
		dir += camera_xform_basis.z
	if Input.is_action_pressed("strafe_left"):
		dir += -camera_xform_basis.x
	if Input.is_action_pressed("strafe_right"):
		dir += camera_xform_basis.x
	
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			velocity.y += JUMP_HEIGHT
	
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
	
	if get_tree().has_network_peer():
		rpc_unreliable("peer_movement", velocity)
	
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))


remote func peer_movement(peer_velocity):
	velocity = peer_velocity


func spawn(spawn_xform : Transform):
	var xform = get_global_transform()
	
	xform.origin.x = spawn_xform.origin.x
	xform.origin.z = spawn_xform.origin.z
	
	set_global_transform(xform)
