@tool
extends EditorScript

var components = []

func _process(delta):
	pass

func get_class():
	print('entity')

func _add_component(node):
	components.append(node)
