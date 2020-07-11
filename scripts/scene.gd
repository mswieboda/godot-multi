extends Node

var current_scene = null


func change(scene : Node):
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	call_deferred("_deferred_scene", scene)


func _deferred_scene(scene : Node):
	current_scene.free()
	current_scene = scene
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
