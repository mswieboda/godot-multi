extends StaticBody

const HEIGHT_LAYERING_RATIO = 0.01

func bullet_hit(damage : int, ray : RayCast, node : Node):
	var position = ray.get_collision_point()
	var normal = ray.get_collision_normal()
	
	print(get_name(), " hit with ", damage, " damage, at: ", position, " normal: ", normal)
	
	add_child(node)
	node.global_transform.origin = position + normal * HEIGHT_LAYERING_RATIO
	
	var rel_normal = node.global_transform.origin + normal
	
	node.look_at(rel_normal, Vector3.UP)
