extends Weapon

const AUTO_FIRE = true
const FIRE_RATE = 0.075
const DAMAGE = 2.5
const ZOOM_RATIO = 2.5
const INITIAL_ACCURACY = 0.025

func _init().(
	AUTO_FIRE, 
	FIRE_RATE, 
	DAMAGE, 
	ZOOM_RATIO, 
	INITIAL_ACCURACY
):
	pass

func play(animation : String):
	$model/AnimationPlayer.play(animation)
