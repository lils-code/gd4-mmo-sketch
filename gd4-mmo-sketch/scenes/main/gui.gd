extends Control

@onready var character = $character_panel
@onready var target = $target_panel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_target(e):
	if str(e) == '':
		target.visible = false
	else:
		target.visible = true
