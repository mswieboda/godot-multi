extends Spatial

const DAMAGE = 5

var bullet_hole = preload("res://objs/pistol/bullet_hole.tscn")


func fire():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("default")
	
#	var ray = $raycast
	var ray = get_parent().get_node("camera/raycast")
	
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var body_parent = ray.get_collider().get_parent()
		
		if body_parent.has_method("weapon_hit"):
			var position = ray.get_collision_point()
			var normal = ray.get_collision_normal()
			body_parent.weapon_hit(self, position, normal)


func hit_texture(obj : Node, position : Vector3, normal : Vector3, height_layering_ratio : float):
	var node : Node = bullet_hole.instance()
	obj.add_child(node)
	node.global_transform.origin = position
	node.global_transform.basis = Global.perpendicular_basis_from_normal(normal)
	node.global_transform.origin += normal * height_layering_ratio


func damage():
	return DAMAGE

