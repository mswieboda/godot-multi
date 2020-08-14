extends KinematicBody

const GRAVITY = -9.8 * 9.8
const MOUSE_SENSITIVITY = 0.003
const MAX_VERTICAL_LOOK = 1.25
const MAX_HEALTH = 100

export var JUMP_HEIGHT = 33
export var SPEED = 6
export var ACCELERATION = 3
export var DEACCELERATION = 5
export var PLAYABLE = true

var is_moving = false
var is_dead = false
var velocity = Vector3()
var health : float = MAX_HEALTH
var pickups = []
var pickup_index = 0
var weapons = []
var weapon_index = 0
var weapon : Node

func _ready():
	if is_playable():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$head/mesh.hide()
		$hud.show()
		
		# debugging adds initial weapon
		var pistol = load("res://objs/pistol/pistol.tscn").instance()
		weapons.append(pistol)
		pistol.pickup($cam_pivot)
		change_weapon()


func _physics_process(delta):
	movement(delta)


func _unhandled_input(event):
	if !is_playable():
		return
	unhandled_input_actions(event)
	camera_movement(event)
	mouse_capture(event)


func is_playable() -> bool:
	var not_dead_playable = !is_dead && PLAYABLE
	if not_dead_playable:
		if is_networked():
			return is_network_master()
	return not_dead_playable


func is_networked() -> bool:
	return get_tree().has_network_peer()


func hit_texture(_resource : String, position : Vector3, normal : Vector3):
	hit_fx(position, normal)
	
	if is_networked():
		rpc("hit_fx", position, normal)


func hit(player : Node, hit_weapon : Node, shape_index : int, _position : Vector3, _normal : Vector3):
	var damage = calc_damage(shape_index, hit_weapon.damage)
	
	take_damage(damage)
	
	if is_networked():
		rpc("take_damage", damage)
	
	player.show_damage(damage, health)


remote func hit_fx(position : Vector3, normal : Vector3):
	if is_playable():
		return
	
	var fx = preload("res://objs/bullet_hit_fx/bullet_hit_fx.tscn").instance()
	fx.emitting = true

	add_child(fx)

	fx.global_transform.origin = position
	fx.global_transform.basis = Global.perpendicular_basis_from_normal(normal)
	fx.global_transform.origin += normal * Global.HEIGHT_LAYERING_RATIO


func calc_damage(shape_index : int, damage : float) -> float:
	var shape = shape_owner_get_owner(shape_find_owner(shape_index))
	
	if shape.get_name() == "head":
		damage *= 10
	
	return damage


remote func take_damage(damage : float):
	health -= damage

	if is_playable():
		$hud/damage_flash.start()
	
	if health <= 0:
		die()


func show_damage(damage : float, health_left : float):
	$hud/center/hit_info.start(damage, health_left)


func die():
	if is_dead:
		return
	
	health = 0
	
	# TODO: TEMP, needs more work, gravity drop to floor, animate somehow?
	var position = global_transform.origin
	var dead_body = preload("res://objs/dead_body/dead_body.tscn").instance()
	get_parent().add_child(dead_body)
	dead_body.global_transform.origin = position
	
	is_dead = true
	$body.disabled = true
	$head.disabled = true
	hide()

func enable_camera():
	$cam_pivot/camera.set_current(true)


func disable_camera():
	$cam_pivot/camera.set_current(false)


func set_color(color : Color):
	$body/mesh.material_override = SpatialMaterial.new()
	$body/mesh.material_override.albedo_color = color


func camera_movement(event : InputEvent):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
		
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		$cam_pivot.rotate_x(event.relative.y * MOUSE_SENSITIVITY)
		$cam_pivot.rotation.x = clamp($cam_pivot.rotation.x, -MAX_VERTICAL_LOOK, MAX_VERTICAL_LOOK)


func unhandled_input_actions(event : InputEvent):
	if event.is_action_pressed("test"):
		hit(self, weapon, 0, Vector3(), Vector3())
	
	if event.is_action_pressed("action"):
		if pickups.size() > 0:
			var pickup = pickups[pickup_index]
			
			if pickup is Weapon:
				weapons.append(pickup)
				pickups.erase(pickup)
				pickup_index = 0
				pickup.pickup($cam_pivot)
				change_weapon_up()
	
	if event.is_action_pressed("weapon_up"):
		change_weapon_up()
	
	if event.is_action_pressed("weapon_down"):
		change_weapon_down()
	
	if event.is_action_pressed("ui_focus_next"):
		pickup_index += 1
		
		if pickup_index >= pickups.size():
			pickup_index = 0
		
		pickups_hud()
	elif event.is_action_pressed("ui_focus_prev"):
		pickup_index -= 1
		
		if pickup_index <= 0:
			pickup_index = pickups.size() - 1
		
		pickups_hud()


func mouse_capture(event : InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


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

	if is_networked():
		rpc_unreliable("peer_movement", velocity)

	velocity = move_and_slide(velocity, Vector3(0, 1, 0))


remote func peer_movement(peer_velocity):
	velocity = peer_velocity


func spawn(spawn_xform : Transform):
	var xform = get_global_transform()

	xform.origin.x = spawn_xform.origin.x
	xform.origin.z = spawn_xform.origin.z

	set_global_transform(xform)


func pickup_entered(pickup : Node):
	if !is_playable():
		return
	
	pickups.append(pickup)
	pickups_hud()


func pickup_exited(pickup : Node):
	if !is_playable():
		return
	
	pickups.erase(pickup)
	pickups_hud()


func pickups_hud():
	var text = ""
	if pickups.size() > 0:
		$hud/pickup_info.show()
		
		text = "press E to pickup " + pickups[pickup_index].get_name()
		
		if pickups.size() > 1:
			text += "\npickups: "
			
			for i in pickups.size():
				var pickup = pickups[i]
				text += pickup.get_name() + ", " if i < pickups.size() - 1 else pickup.get_name()
			
			text += "\npress TAB (and SHIFT+TAB) to switch pickups"
	else:
		pickup_index = 0
		$hud/pickup_info.hide()
	
	$hud/pickup_info.text = text


func change_weapon_up():
	weapon_index += 1
	if weapon_index >= len(weapons):
		weapon_index = 0
	change_weapon()


func change_weapon_down():
	weapon_index -= 1
	if weapon_index < 0:
		weapon_index = len(weapons) - 1
	change_weapon()


func change_weapon():
	if weapon:
		$cam_pivot.remove_child(weapon)
	
	weapon = weapons[weapon_index]

	if !weapon.get_parent():
		$cam_pivot.add_child(weapon)
