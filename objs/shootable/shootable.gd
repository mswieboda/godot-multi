extends Spatial

const HEIGHT_LAYERING_RATIO = 0.01

func bullet_hit(damage : int, ray : RayCast, node : Node):
	var position = ray.get_collision_point()
	var normal = ray.get_collision_normal()
	
	print(get_name(), " hit with ", damage, " damage, at: ", position, " normal: ", normal)
	
	add_child(node)
	node.global_transform.origin = position

	# WORKS:	
#	var rel_normal = node.global_transform.origin + normal	
#	node.look_at(rel_normal, Vector3.UP)

	# TESTING:
#	node.rotation_degrees = normal
	
	# TESTING:
#	if node is Sprite3D:
#		node.global_transform.origin += normal * (node.texture.get_width() / 2.0 * node.pixel_size)
#		node.global_transform.origin += normal.y * (node.texture.get_height() * node.pixel_size)
	
	node.global_transform.basis = perpendicular_basis_from_normal(normal)
	
	node.global_transform.origin += normal * HEIGHT_LAYERING_RATIO
	

func perpendicular_basis_from_normal(normal : Vector3):
	# Find the axis with the smallest component
	var min_ind = 0
	var min_axis = abs(normal.x)
	
	if abs(normal.y) < min_axis:
		min_ind = 1
		min_axis = abs(normal.y)
	if abs(normal.z) < min_axis:
			min_ind = 2
	
	var right
	
	# Leave the minimum axis in its place, 
	# swap the other two to get a vector perpendicular to the normal vector
	if min_ind == 0:
		right = Vector3(normal.x, -normal.z, normal.y)
	elif min_ind == 1:
		right = Vector3(-normal.z, normal.y, normal.x)
	elif min_ind == 2:
		right = Vector3(-normal.y, normal.x, normal.z)
	
	var up = normal.cross(right)
	return Basis(right, up, normal)
