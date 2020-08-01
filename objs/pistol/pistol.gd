extends Spatial

func fire():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("default")
