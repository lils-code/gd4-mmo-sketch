@tool
extends EditorPlugin

const icon : CompressedTexture2D = preload("res://addons/entity_creation/entity.svg")
const entity_class : Script = preload("res://addons/entity_creation/entity.gd")

const entity_property_class : Script = preload("res://addons/entity_creation/entity-property.gd")
var entity_property_panel : EditorInspectorPlugin = entity_property_class.new()

func _apply_changes() -> void:
	print('saved')

func _enter_tree():
	add_custom_type('entity', 'Node', entity_class, icon)

func _exit_tree():
	remove_custom_type('entity')
