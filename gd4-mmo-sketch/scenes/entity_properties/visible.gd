@tool
extends MeshInstance3D

@export var occlude : bool = false :
	set = _set_occlude
@export var use_as_static_collider : bool = false 


func _set_occlude(v : bool) -> void:
	occlude = v
	if occlude:
		var vis = VisibleOnScreenEnabler3D.new()
		vis.name = 'occluded'
		add_child(vis, true)
		vis.set_owner(owner)
	else:
		var vis = get_node('occluded')
		if vis:
			vis.queue_free()
