extends Spatial
class_name Weapon

const PICKUP_SCALE = 3

var player
var camera
var raycast
var tween
var initial_camera_fov
var rng = RandomNumberGenerator.new()

var auto_fire = false
var fire_rate = 0.5
var damage = 5
var zoom_ratio = 1.75
var hit_texture_path = "res://objs/bullet_hole/bullet_hole.tscn"
var initial_accuracy = 0.005

var is_pickup = true
var is_firing = false
var is_firing_done = true
var has_fired_delta = 0
var enabled = false
var is_aiming = false


func _init(
	_auto_fire = auto_fire, 
	_fire_rate = fire_rate, 
	_damage = damage, 
	_zoom_ratio = zoom_ratio, 
	_initial_accuracy = initial_accuracy,
	_hit_texture_path = hit_texture_path
):
	rng.randomize()
	auto_fire = _auto_fire
	fire_rate = _fire_rate
	damage = _damage
	zoom_ratio = _zoom_ratio
	initial_accuracy = _initial_accuracy
	hit_texture_path = _hit_texture_path


func _ready():
	if !enabled:
		scale = Vector3.ONE * PICKUP_SCALE


func pickup_init(cam_pivot):
	player = cam_pivot.get_parent()
	camera = cam_pivot.get_node_or_null("camera")
	
	if player and camera:
		camera = cam_pivot.get_node("camera")
		raycast = camera.get_node("raycast")
		tween = camera.get_node("tween")
		initial_camera_fov = camera.fov
	
		if player.is_playable():
			is_pickup = false
			enabled = true
			$hud.show()


func _physics_process(_delta):
	if !enabled:
		return
	if auto_fire and Input.is_action_pressed("fire"):
		fire()
	if Input.is_action_pressed("aim"):
		start_aim()
	else:
		start_unaim()


func _process(delta):
	if !enabled:
		return
	
	if is_firing:
		has_fired_delta += delta
		
		if has_fired_delta > fire_rate:
			has_fired_delta = 0
			is_firing_done = false
			is_firing = false
	elif auto_fire and !is_firing_done:
		has_fired_delta += delta
		
		if has_fired_delta > fire_rate:
			has_fired_delta = 0
			is_firing_done = true
			play("fire_done")


func _unhandled_input(event):
	if !enabled:
		return
	if !auto_fire and event.is_action_pressed("fire"):
		fire()


func fire():
	if !enabled or is_firing:
		return
	
	is_firing = true
	
	if !auto_fire or (auto_fire and is_firing_done):
		play("fire")
	
	var radians_x = rng.randf_range(-initial_accuracy, initial_accuracy)
	var radians_y = rng.randf_range(-initial_accuracy, initial_accuracy)
	
	raycast.rotate_x(radians_x)
	raycast.rotate_y(radians_y)
	
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var body = raycast.get_collider()
		var position = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		var shape_index = raycast.get_collider_shape()
		
		if body.has_method("hit_texture"):
			body.hit_texture(hit_texture_path, position, normal)
		
		if body.has_method("hit"):
			body.hit(player, self, shape_index, position, normal)
	
	raycast.rotation = Vector3(0, 0, 0)


func pickup(cam_pivot : Node):
	if get_parent():
		get_parent().remove_child(self)
	cam_pivot.get_node("body/arm/hand").add_child(self)
	pickup_init(cam_pivot)
	
	scale = Vector3.ONE
	translation = Vector3.ZERO
	rotation_degrees = Vector3(0, 90, 0)
	# TODO: this is a hack, reset translation a better way?
#	$AnimationPlayer.play_backwards("aim")


func input_actions(_delta):
	if !enabled:
		return
	
	if Input.is_action_pressed("aim"):
		start_aim()
	else:
		start_unaim()


func play(_animation : String):
	pass


func start_aim():
	if is_aiming == true:
		return
	
	is_aiming = true
	aim()


func start_unaim():
	if is_aiming == false:
		return

	is_aiming = false
	unaim()


func aim():
	zoom(1 / zoom_ratio)
#	$AnimationPlayer.play("aim")


func unaim():
	zoom(1)
#	$AnimationPlayer.play_backwards("aim")


func zoom(zoom):
	if initial_camera_fov == null:
		initial_camera_fov = camera.fov

	tween.interpolate_property(camera, "fov", null, initial_camera_fov * zoom, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)	
	tween.start()


func _on_area_body_entered(body):
	if enabled:
		return
	if body.has_method("pickup_entered"):
		body.pickup_entered(self)


func _on_area_body_exited(body):
	if enabled:
		return
	if body.has_method("pickup_exited"):
		body.pickup_exited(self)
