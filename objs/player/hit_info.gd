extends MarginContainer


export var FRAMES = 10

var frame = 0


func _process(_delta):
	if frame > 0:
		if frame > FRAMES:
			stop()
		else:
			frame += 1


func start(damage, health):
	$container/damage.text = str(damage)
	$container/health.text = str(health)
	
	show()
	frame = 1


func stop():
	hide()
	frame = 0
