extends MarginContainer


export var FRAMES = 25

var frame = 0


func _process(_delta):
	if frame > 0:
		if frame > FRAMES:
			stop()
		else:
			frame += 1


func start(damage : float, health : float):
	$container/damage.text = "%.1f" % damage
	$container/health.text = "%.1f" % health
	
	show()
	frame = 1


func stop():
	hide()
	frame = 0
