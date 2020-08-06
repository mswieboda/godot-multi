extends Spatial

const DAMAGE = 5

var bullet_hole = preload("res://objs/pistol/bullet_hole.tscn")


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
			body.hit_texture(shape_index, position, normal)
		else:
			hit_texture(body, position, normal)
			rpc("hit_texture", body, position, normal)
		
		if body.has_method("hit"):
			body.hit(player, self, shape_index, position, normal)


remote func hit_texture(body : Node, position : Vector3, normal : Vector3, height_layering_ratio : float = Global.HEIGHT_LAYERING_RATIO):
	var node : Node = bullet_hole.instance()
	body.add_child(node)
	node.global_transform.origin = position
	node.global_transform.basis = Global.perpendicular_basis_from_normal(normal)
	node.global_transform.origin += normal * height_layering_ratio


func damage():
	return DAMAGE

