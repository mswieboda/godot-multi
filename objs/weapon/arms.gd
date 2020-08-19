extends Spatial

var arms
var player
var camera
var raycast
var tween
var initial_camera_fov


onready var weapon : Node = get_weapon()


var is_aiming = false


func _physics_process(_delta):
	if weapon.auto_fire and Input.is_action_pressed("fire"):
		fire()
	if Input.is_action_pressed("aim"):
		aim()
	else:
		unaim()


func _unhandled_input(event):
	if !weapon.auto_fire and event.is_action_pressed("fire"):
		fire()


func get_weapon():
	pass


func pickup_init(cam_pivot):
	arms = cam_pivot.get_node("body/arms")
	arms.add_child(self)
	
	player = cam_pivot.get_parent()
	camera = cam_pivot.get_node("camera")
	
	raycast = camera.get_node("raycast")
	
	tween = camera.get_node("tween")
	initial_camera_fov = camera.fov
	
	weapon.enabled = true


func fire():
	weapon.fire(player, raycast)


func aim():
	if is_aiming == true:
		return
	
	is_aiming = true
	zoom(1 / weapon.zoom_ratio)
	$AnimationPlayer.play("aim")


func unaim():
	if is_aiming == false:
		return

	is_aiming = false
	zoom(1)
	$AnimationPlayer.play_backwards("aim")


func zoom(zoom):
	if initial_camera_fov == null:
		initial_camera_fov = camera.fov

	tween.interpolate_property(camera, "fov", null, initial_camera_fov * zoom, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
