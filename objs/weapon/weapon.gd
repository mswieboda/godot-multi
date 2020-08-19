extends Spatial
class_name Weapon

const PICKUP_SCALE = 3

var arms
var rng = RandomNumberGenerator.new()

var auto_fire = false
var fire_rate = 0.5
var damage = 5
var zoom_ratio = 1.75
var arms_resource_path
var hit_texture_resource_path
var initial_accuracy = 0.005

var is_pickup = true
var is_firing = false
var is_firing_done = true
var has_fired_delta = 0
var enabled = false setget set_enabled


func _init(
	_auto_fire = auto_fire, 
	_fire_rate = fire_rate, 
	_damage = damage, 
	_zoom_ratio = zoom_ratio, 
	_initial_accuracy = initial_accuracy,
	_arms_resource_path = arms_resource_path,
	_hit_texture_resource_path = hit_texture_resource_path # TODO: switch to resource like arms
):
	rng.randomize()
	auto_fire = _auto_fire
	fire_rate = _fire_rate
	damage = _damage
	zoom_ratio = _zoom_ratio
	initial_accuracy = _initial_accuracy
	arms_resource_path = _arms_resource_path
	hit_texture_resource_path = _hit_texture_resource_path


func _ready():
	set_enabled(enabled)


func _process(delta):
	if !enabled:
		return
	
	if is_firing:
		has_fired_delta += delta
		
		if has_fired_delta > fire_rate:
			has_fired_delta = 0
			is_firing_done = false
			is_firing = false
	elif auto_fire and !is_firing_done:
		has_fired_delta += delta
		
		if has_fired_delta > fire_rate:
			has_fired_delta = 0
			is_firing_done = true
			play("fire_done")


func set_enabled(_enabled):
	enabled = _enabled
	
	if enabled:
		scale = Vector3.ONE
	else:
		scale = Vector3.ONE * PICKUP_SCALE


func fire(player, raycast):
	is_firing = true
	
	if !auto_fire or (auto_fire and is_firing_done):
		play("fire")
	
	var radians_x = rng.randf_range(-initial_accuracy, initial_accuracy)
	var radians_y = rng.randf_range(-initial_accuracy, initial_accuracy)
	
	raycast.rotate_x(radians_x)
	raycast.rotate_y(radians_y)
	
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var body = raycast.get_collider()
		var position = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		var shape_index = raycast.get_collider_shape()
		
		if body.has_method("hit_texture"):
			body.hit_texture(hit_texture_resource_path, position, normal)
		
		if body.has_method("hit"):
			body.hit(player, self, shape_index, position, normal)
	
	raycast.rotation = Vector3(0, 0, 0)


func pickup(cam_pivot : Node):
	if get_parent():
		get_parent().remove_child(self)
	
	arms = load(arms_resource_path).instance()
	arms.pickup_init(cam_pivot)
	return arms


func play(_animation : String):
	pass


func _on_area_body_entered(body):
	if enabled:
		return
	if body.has_method("pickup_entered"):
		body.pickup_entered(self)


func _on_area_body_exited(body):
	if enabled:
		return
	if body.has_method("pickup_exited"):
		body.pickup_exited(self)
