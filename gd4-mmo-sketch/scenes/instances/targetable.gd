extends Area3D

@export_node_path var target
@export_node_path(CollisionShape3D) var shape

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_class():
	return "targetable"

func _enter_tree():
	get_parent()._add_component(self)

func get_target():
	return target
