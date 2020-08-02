extends Spatial

const HEIGHT_LAYERING_RATIO = 0.01

func weapon_hit(weapon : Node, position : Vector3, normal : Vector3):
	if weapon.has_method("hit_texture"):
		weapon.hit_texture(self, position, normal, HEIGHT_LAYERING_RATIO)
