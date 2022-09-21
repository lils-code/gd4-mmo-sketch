extends CharacterBody3D

@onready var cam_center = $cam_center
@onready var arm = $cam_center/arm
@onready var cam = $cam_center/camera

const sens = 0.8

const speed = 5
const accel = 0.5

var cur_accel = 0

const gravity = 19

const jump_vel = 15
const jump_len = 0.25
const jump_fall_off = 0.2
const jump_over_shoot = 0.2

var cur_jump_len = 0
var jump = false

const rot_speed = 0.03
const snap_weight = 0.05

var prev_cap = false
var mouse_vel = Vector2.ZERO
var mouse_pos = Vector2.ZERO

var total_y_rot = 0

enum move_types {
	DEFAULT,
	STRAFE,
	MOUSE
}

var move_type = move_types.DEFAULT

func short_angle_dist(from, to):
	var dif = fmod(to - from, PI * 2)
	return fmod(2 * dif, PI * 2) - dif

func _input(event):
	if event is InputEventMouseMotion:
		rot(event)
	if event is InputEventMouseButton:
		rot(InputEventMouseMotion.new())

func _physics_process(delta):
	y_vel(delta)

	xz_vel(delta)
	
	move_and_slide()

func rot(event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MASK_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_MASK_RIGHT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		prev_cap = true
		
		var rot_y = sens * (-event.relative.y / 500)
		
		if total_y_rot + rot_y < 0.25 * PI and total_y_rot + rot_y > -0.4 * PI:
			cam_center.rotate(cam_center.transform.basis.x, rot_y)
			total_y_rot += rot_y
		
		var rot_x = sens * (-event.relative.x / 500)
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MASK_RIGHT):
			if cam_center.global_rotation.y != 0:
				rotation.y = cam_center.global_rotation.y
				cam_center.rotation.y = 0
			
			rotate_y(rot_x)
			
			move_type = move_types.STRAFE
		else:
			cam_center.rotate_y(rot_x)
			
			move_type = move_types.DEFAULT
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MASK_LEFT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_MASK_RIGHT):
			move_type = move_types.MOUSE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		if prev_cap:
			Input.warp_mouse(mouse_pos)
			prev_cap = false
			move_type = move_types.DEFAULT
			
		mouse_pos = get_viewport().get_mouse_position()
	
	collide()

func collide():
	print(ray.get_collision_point())
	#var space_state = get_world().direct_space_state
	pass

func y_vel(delta):
	var flrtest = is_on_floor()
	
	if flrtest:
		jump = false
		if Input.is_action_just_pressed('jump'):
			jump = true
			cur_jump_len = 0
			velocity.y = jump_vel
	else:
		if jump and not Input.is_action_pressed('jump'):
			jump = false
	
	if jump:
		if cur_jump_len < jump_len:
			velocity.y = jump_vel - ((jump_vel * pow(cur_jump_len, jump_fall_off)) / pow(jump_len + jump_over_shoot, jump_fall_off))
		else:
			jump = false
		
		cur_jump_len += delta
	
	if not flrtest and not jump:
		if Input.is_action_just_released('jump'):
			velocity.y *= 0.66
		
		velocity.y -= gravity * delta

func xz_vel(delta):
	var input_dir = Input.get_vector('left', 'right', 'forward', 'back')
	var scl = input_dir
	
	if move_type == move_types.DEFAULT:
		rotate_y(rot_speed * (-1 * scl.x))
		scl.x = 0
	elif move_type == move_types.MOUSE:
		scl.y = -1
	
	var dir = (transform.basis * Vector3(scl.x, 0, scl.y)).normalized()
	
	if dir == Vector3.ZERO:
		cur_accel -= accel
	else:
		cur_accel += accel
	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_MASK_LEFT) and abs(cam_center.rotation.y) != 0 and input_dir != Vector2.ZERO:
		if abs(cam_center.rotation.y) > 0.01:
			cam_center.rotate_y(short_angle_dist(cam_center.rotation.y, 0) * snap_weight)
		else:
			cam_center.rotation.y = 0
	
	if dir.z > 0:
		dir.z *= 0.5
	
	cur_accel = clamp(cur_accel, 0, speed)
	velocity.x = dir.x * cur_accel
	velocity.z = dir.z * cur_accel
