extends Weapon

const AUTO_FIRE = false
const FIRE_RATE = 0.15
const DAMAGE = 5
const ZOOM_RATIO = 1.5
const INITIAL_ACCURACY = 0.005

func _init().(
	AUTO_FIRE, 
	FIRE_RATE, 
	DAMAGE, 
	ZOOM_RATIO, 
	INITIAL_ACCURACY
):
	pass


func play(animation : String):
	if animation == "fire":
		$model/AnimationPlayer.play("default")
