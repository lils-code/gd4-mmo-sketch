extends Node

var gravity = 25

var jump = {
	'vel': 20,
	'length': 0.25,
	'fall_off': 0.2,
	'over_shoot': 0.2,
}

var is_jumping = false
var cur_jump_len = 0

var speed = 6.66
var accel = 0.5
var cur_accel = 0

func y_vel(e, jump_state, delta):
	var flrtest = e.is_on_floor()
	var r = e.velocity.y
	
	if flrtest:
		is_jumping = false
		if jump_state.x:
			is_jumping = true
			cur_jump_len = 0
			r = jump.vel
	else:
		if is_jumping and not jump_state.y:
			is_jumping = false
	
	if is_jumping:
		if cur_jump_len < jump.length:
			r = jump.vel - ((jump.vel * pow(cur_jump_len, jump.fall_off)) / pow(jump.length + jump.over_shoot, jump.fall_off))
		else:
			is_jumping = false
		
		cur_jump_len += delta
	
	if not flrtest and not is_jumping:
		if Input.is_action_just_released('jump'):
			r *= 0.66
		
		r -= gravity * delta
	
	return r

func xz_vel(e, input_dir, move_type, delta):
	var dir = e.transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	
	if dir == Vector3.ZERO:
		cur_accel -= accel
	else:
		cur_accel += accel
	
	cur_accel = clamp(cur_accel, 0, speed)
	return Vector2(dir.x * cur_accel, dir.z * cur_accel)

func rot(e, vec, input, delta):
	e.rotate(vec, input)
