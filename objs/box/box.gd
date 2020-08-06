extends StaticBody


func hit_texture(resource : String, position : Vector3, normal : Vector3):
	_hit_texture(resource, position, normal)
	
	if get_tree().has_network_peer():
		rpc("_hit_texture", resource, position, normal)


remote func _hit_texture(resource : String, position : Vector3, normal : Vector3):
	var node : Node = load(resource).instance()
	add_child(node)
	node.global_transform.origin = position
	node.global_transform.basis = Global.perpendicular_basis_from_normal(normal)
	node.global_transform.origin += normal * Global.HEIGHT_LAYERING_RATIO
