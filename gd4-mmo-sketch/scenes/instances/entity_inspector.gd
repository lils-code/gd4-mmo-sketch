extends EditorInspectorPlugin

func _init():
	add_property_editor('test', ItemList.new())
