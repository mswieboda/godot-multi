extends Spatial

const DAMAGE = 5

var bullet_hole = "res://objs/pistol/bullet_hole.tscn"


func fire():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("default")
	
	var ray = get_parent().get_node("camera/raycast")
	
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var player = get_parent().get_parent()
		var body = ray.get_collider()
		var position = ray.get_collision_point()
		var normal = ray.get_collision_normal()
		var shape_index = ray.get_collider_shape()
		
		if body.has_method("hit_texture"):
			body.hit_texture(bullet_hole, position, normal)
		
		if body.has_method("hit"):
			body.hit(player, self, shape_index, position, normal)


func damage():
	return DAMAGE

