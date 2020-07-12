extends Camera

export var distance = 4.0
export var height = 2.0


# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)


func _physics_process(_delta):
	var target = get_parent().get_global_transform().origin
	var position = get_global_transform().origin
	var up = Vector3(0, 1, 0)
	var offset = (position - target).normalized() * distance
	
	offset.y = height
	
	look_at_from_position(position, target, up)
	
	
