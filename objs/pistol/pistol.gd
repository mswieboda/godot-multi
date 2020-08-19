extends Weapon

const AUTO_FIRE = false
const FIRE_RATE = 0.15
const DAMAGE = 5
const ZOOM_RATIO = 1.5
const INITIAL_ACCURACY = 0.005
const ARMS_RESOURCE_PATH = "res://objs/pistol/arms.tscn"
const HIT_TEXTURE_RESOURCE_PATH = "res://objs/bullet_hole/bullet_hole.tscn"

func _init().(
	AUTO_FIRE, 
	FIRE_RATE, 
	DAMAGE, 
	ZOOM_RATIO, 
	INITIAL_ACCURACY,
	ARMS_RESOURCE_PATH,
	HIT_TEXTURE_RESOURCE_PATH
):
	pass


func play(animation : String):
	if animation == "fire":
		$model/AnimationPlayer.play("default")
