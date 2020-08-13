extends Spatial
class_name Weapon

var damage = 5
var zoom_ratio = 1.75
var hit_texture_path = "res://objs/bullet_hole/bullet_hole.tscn"

var player
var camera
var raycast
var tween
var initial_camera_fov
var is_pickup = true


func _init(_damage, _zoom_ratio, _hit_texture_path):
	damage = _damage
	zoom_ratio = _zoom_ratio
	hit_texture_path = _hit_texture_path


func _ready():
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

# warning-ignore:shadowed_variable
func fire(raycast = self.raycast):
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
			body.hit_texture(hit_texture_path, position, normal)
		
		if body.has_method("hit"):
			body.hit(player, self, shape_index, position, normal)


func pickup(cam_pivot):
	self.get_parent().remove_child(self)
	cam_pivot.add_child(self)
	_ready()
	
	# TODO: this is a hack, reset translation a better way
	$AnimationPlayer.play_backwards("default")
	$aim_animator.play_backwards("aim")


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
	if body.has_method("pickup_entered"):
		body.pickup_entered(self)


func _on_area_body_exited(body):
	if body.has_method("pickup_exited"):
		body.pickup_exited(self)
