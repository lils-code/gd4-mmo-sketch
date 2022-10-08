@tool
extends Node

const targetable = preload('res://scenes/instances/targetable.tscn')
const visible = preload('res://scenes/instances/visible.tscn')
const phys_static = preload('res://scenes/instances/static.tscn')

const comp_name_list = [
	targetable,
	visible,
	phys_static
]

var comp_array = []

@export_flags('targetable', 'visible', 'phys_static') var components : int = 0 :
	get:
		return components
	set(value):
		components = value
		refresh_components()

func _init():
	comp_array.resize(32)
	for i in range(0, 32):
		comp_array[i] = 0

func bit_at(i : int):
	return int(int(pow(2, i)) & components != 0)

func refresh_components():
	for i in range(0, 32):
		if comp_array[i] == null:
			comp_array[i] = 0
		
		if (str(comp_array[i]) != '0') && (bit_at(i) == 1):
			if bit_at(i) == 1:
				var c = comp_name_list[i].instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
				get_parent().add_child(c)
				c.owner = get_parent()
				comp_array[i] = c.get_path()
				
			else:
				get_node(comp_array[i]).queue_free()
				comp_array[i] = 0
			
		#print(comp_array)
			
