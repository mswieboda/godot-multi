extends Spatial
class_name Weapon

var player
var camera
var raycast
var tween
var initial_camera_fov

var auto_fire = false
var fire_rate = 0.5
var damage = 5
var zoom_ratio = 1.75
var hit_texture_path = "res://objs/bullet_hole/bullet_hole.tscn"
var is_pickup = true
var is_firing = false
var has_fired_delta = 0
var enabled = false
var is_aiming = false


func _init(_auto_fire, _fire_rate, _damage, _zoom_ratio, _hit_texture_path):
	auto_fire = _auto_fire
	fire_rate = _fire_rate
	damage = _damage
	zoom_ratio = _zoom_ratio
	hit_texture_path = _hit_texture_path


func _ready():
	if !enabled:
		return
	var camera_pivot = get_parent()
	player = camera_pivot.get_parent()
	camera = camera_pivot.get_node_or_null("camera")
	
	if player and camera:
		camera = camera_pivot.get_node("camera")
		raycast = camera.get_node("raycast")
		tween = camera.get_node("tween")
		initial_camera_fov = camera.fov
	
		if player.is_playable():
			is_pickup = false
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
			is_firing = false


func _unhandled_input(event):
	if !enabled:
		return
	if !auto_fire and event.is_action_pressed("fire"):
		fire()


# warning-ignore:shadowed_variable
func fire():
	if !enabled or is_firing:
		return
	
	is_firing = true
	$AnimationPlayer.play("fire")
	
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var player = get_parent().get_parent()
		var body = raycast.get_collider()
		var position = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		var shape_index = raycast.get_collider_shape()
		
		if body.has_method("hit_texture"):
			body.hit_texture(hit_texture_path, position, normal)
		
		if body.has_method("hit"):
			body.hit(player, self, shape_index, position, normal)


func pickup(cam_pivot):
	if get_parent():
		get_parent().remove_child(self)
	cam_pivot.add_child(self)
	enabled = true
	_ready()
	
	# TODO: this is a hack, reset translation a better way
	$AnimationPlayer.play_backwards("fire")
	$aim_animator.play_backwards("aim")


func input_actions(_delta):
	if !enabled:
		return
	
	if Input.is_action_pressed("aim"):
		start_aim()
	else:
		start_unaim()


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
	$aim_animator.play("aim")


func unaim():
	zoom(1)
	$aim_animator.play_backwards("aim")


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
