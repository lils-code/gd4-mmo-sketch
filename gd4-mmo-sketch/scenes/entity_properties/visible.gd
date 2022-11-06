@tool
extends MeshInstance3D

class_name visible

@export var occlude : bool = false :
	set = _set_occlude
@export var use_as_static_collider : bool = false :
	set = _set_use_as_static_collider

func _set_occlude(v : bool) -> void:
	occlude = v
	if occlude:
		var vis = VisibleOnScreenEnabler3D.new()
		add_child(vis)
		
		vis.name = 'occluded'
		vis.set_owner(owner)
	else:
		var vis = get_node('occluded')
		if vis:
			vis.queue_free()

func _set_use_as_static_collider(v : bool) -> void:
	use_as_static_collider = v
	if use_as_static_collider:
		var s = StaticBody3D.new()
		add_child(s)
		
		s.name = 'static'
		s.set_owner(owner)
	else:
		var s = get_node('static')
		if s:
			s.queue_free()

func _ready() -> void:
	name = 'visible'
