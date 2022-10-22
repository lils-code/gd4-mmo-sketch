@tool
extends Node

@export_flags('test') var flags : int = 0 :
	set = _set_flags

func _set_flags(v : int) -> void:
	flags = v
	print('changed')
