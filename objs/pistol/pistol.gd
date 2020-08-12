extends Spatial

const DAMAGE = 5
const PISTOL_ZOOM = 1.75
const BULLET_HOLE = "res://objs/pistol/bullet_hole.tscn"

var player
var camera
var raycast
var tween
var initial_camera_fov

func _ready():
	var camera_pivot = get_parent()
	player = camera_pivot.get_parent()
	camera = camera_pivot.get_node("camera")
	raycast = camera.get_node("raycast")
	tween = camera.get_node("tween")
	initial_camera_fov = camera.fov
	
	if player.is_playable():
		$hud.show()

func fire():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("fire")
	
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var player = get_parent().get_parent()
		var body = raycast.get_collider()
		var position = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		var shape_index = raycast.get_collider_shape()
		
		if body.has_method("hit_texture"):
			body.hit_texture(BULLET_HOLE, position, normal)
		
		if body.has_method("hit"):
			body.hit(player, self, shape_index, position, normal)


func damage():
	return DAMAGE


func aim():
	zoom(1 / PISTOL_ZOOM)
	$aim_animator.play("aim")


func unaim():
	zoom(1)
	$aim_animator.play_backwards("aim")


func zoom(zoom_factor):
	if initial_camera_fov == null:
		initial_camera_fov = camera.fov

	tween.interpolate_property(camera, "fov", null, initial_camera_fov * zoom_factor, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)	
	tween.start()
