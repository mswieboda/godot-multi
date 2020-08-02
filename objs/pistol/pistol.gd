extends Spatial

const DAMAGE = 5

var bullet_hole = preload("res://objs/pistol/bullet_hole.tscn")


func fire():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("default")
	
	var ray = $raycast
	
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var body_parent = ray.get_collider().get_parent()
		
		if body_parent.has_method("bullet_hit"):
			body_parent.bullet_hit(DAMAGE, ray, bullet_hole.instance())
