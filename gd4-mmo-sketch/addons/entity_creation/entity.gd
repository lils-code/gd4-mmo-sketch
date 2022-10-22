@tool
extends Node3D

@export_flags('test') var flags : int = 0

func _set_flags(v : int) -> void:
	flags = v
	
func _get_property_list() -> Array:
	return get_property_list()
