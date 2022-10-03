extends CharacterBody3D

var movement = preload("res://scenes/main/movement.gd").new()

func _physics_process(delta):
	var jump_state = Vector2(false, false)
	velocity.y = movement.y_vel(self, jump_state, delta)

	move_and_slide()
