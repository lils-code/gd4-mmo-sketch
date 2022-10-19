extends EditorPlugin
@tool

const inspector_plugin_path : Script = preload("res://scenes/instances/entity_inspector.gd")
var inspector_plugin : EditorInspectorPlugin = inspector_plugin_path.new()

func _enter_tree():
	add_inspector_plugin(inspector_plugin)

func _exit_tree():
	remove_inspector_plugin(inspector_plugin)
