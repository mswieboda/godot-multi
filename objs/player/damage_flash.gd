extends ColorRect

export var FRAMES = 5

var frame = 0


func _process(_delta):
	if frame > 0:
		if frame > FRAMES:
			stop()
		else:
			frame += 1


func start():
	show()
	frame = 1


func stop():
	hide()
	frame = 0
