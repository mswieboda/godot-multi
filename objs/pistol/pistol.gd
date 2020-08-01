extends Spatial

func fire():
	print("fire!")
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("default")
