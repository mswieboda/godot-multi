extends Weapon

const AUTO_FIRE = true
const FIRE_RATE = 0.075
const DAMAGE = 2.5
const ZOOM_RATIO = 2.5
const INITIAL_ACCURACY = 0.025
const ARMS_RESOURCE_PATH = "res://objs/rifle/arms.tscn"
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
	$model/AnimationPlayer.play(animation)
