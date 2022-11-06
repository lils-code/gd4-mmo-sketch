@tool
extends Node3D

const properties : Array[Dictionary] = [
	{
		'name' = 'visible',
		'scene' = preload("res://scenes/entity_properties/visible.tscn"),
	},
	{
		'name' = 'targetable',
		'scene' = preload("res://scenes/entity_properties/targetable.tscn"),
	}
]

@export_flags('visible', 'targetable') var flags : int = 0 :
	set = _set_flags

func _set_flags(v : int) -> void:
	toggle(flags ^ v, flags)
	
	flags = v

func _enter_tree():
	for i in get_children():
		i.name = '-'

func toggle(dec : int, f : int) -> void:
	var cur : Array[StringName] = get_current_properties()
	
	var binary : Array[int] = []
	binary.resize(32)
	binary.fill(0)
	
	var id : int = 0
	
	while dec > 0:
		binary[id] = dec % 2
		if dec % 2 == 1:
			if f % 2 == 1:
				binary[id] = -1
			toggle_property(id, binary[id], cur)
		id += 1
		dec /= 2
		f /= 2

func get_current_properties() -> Array[StringName]:
	var r : Array[StringName] = []
	
	for i in get_children():
		r.append(i.name)
	
	return r

func toggle_property(i : int, sign : int, cur : Array[StringName]) -> void:
	var property_name : StringName = StringName(properties[i].name)
	
	if sign == 1 && !cur.has(property_name):
		var instance : Node = properties[i].scene.instantiate()
		add_child(instance, true)
		
		instance.owner = owner
	elif sign == -1 and cur.has(property_name):
		
		get_node(properties[i].name).queue_free()
