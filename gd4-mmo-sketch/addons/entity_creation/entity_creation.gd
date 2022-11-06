@tool
extends EditorPlugin

const icon : CompressedTexture2D = preload("res://addons/entity_creation/entity.svg")
const entity_class : Script = preload("res://addons/entity_creation/entity.gd")

func _enter_tree() -> void:
	add_custom_type('entity', 'Node3D', entity_class, icon)

func _apply_changes() -> void:
	print('saved')

func _exit_tree():
	remove_custom_type('entity')
