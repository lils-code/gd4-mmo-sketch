extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _init():
	print('here')
	pass # Replace with function bo

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_class():
	return "visible"

func _enter_tree():
	get_parent()._add_component(self)
