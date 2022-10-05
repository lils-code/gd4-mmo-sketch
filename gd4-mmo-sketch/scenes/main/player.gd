extends CharacterBody3D

var movement = preload('res://scenes/instances/movement.gd').new()

var components = []

@onready var cam_center = $cam_center
@onready var arm = $cam_center/arm
@onready var cam = $cam_center/arm/camera
@onready var gui = $gui

var time = 0

var target = ''

var sens = 1
var key_turn_sens = 0.4

const rot_speed = 0.03
const snap_weight = 0.08

var mouse_pos = Vector2.ZERO
var mouse_vel = 0

var min_arm_len = 2
var max_arm_len = 8.5
var total_y_rot = 0

enum move_types {
	DEFAULT,
	STRAFE,
	MOUSE
}

var move_type = move_types.DEFAULT
var auto_walk = false

var m1_just_pressed = 0
var m1_pressed_pos = 0
var m1_hold = false

func short_angle_dist(from, to):
	var dif = fmod(to - from, PI * 2)
	return fmod(2 * dif, PI * 2) - dif

func _input(event):
	if event is InputEventMouseMotion:
		if move_type == move_types.DEFAULT:
			mouse_pos = event.global_position
		
		mouse_vel = event.relative.length()
		if Input.is_action_pressed('m2'):
			movement.rot(self, Vector3.UP, sens * event.relative.x / -750, 0)
		if m1_hold:
			cam_center.rotate(Vector3.UP, sens * event.relative.x / -330)
		if Input.is_action_pressed('m1') || Input.is_action_pressed('m2'):
			var y_rot = sens * event.relative.y / -330
			y_rot = clamp(total_y_rot + y_rot, -0.4 * PI, 0.1 * PI) - total_y_rot
			total_y_rot += y_rot
			
			cam_center.rotate(cam_center.transform.basis.x, y_rot)
	
	if Input.is_action_just_pressed('auto_walk'):
		auto_walk = !auto_walk
	
	if Input.is_action_pressed('cam_scroll_up'):
		arm.spring_length = clamp(arm.spring_length - 0.2, min_arm_len, max_arm_len)
	elif Input.is_action_pressed('cam_scroll_down'):
		arm.spring_length = clamp(arm.spring_length + 0.2, min_arm_len, max_arm_len)
	
	if Input.is_action_just_released('m2'):
		Input.warp_mouse(mouse_pos)
	
	if Input.is_action_just_pressed('m1'):
		m1_just_pressed = Time.get_unix_time_from_system()
		m1_pressed_pos = mouse_pos
	elif Input.is_action_just_released('m1'):
		if m1_hold == false:
			find_target()
		
		m1_hold = false
		
	if Input.is_action_pressed('ui_cancel'):
		if str(target) != '':
			target = ''
			gui.change_target(target)
		else:
			get_tree().quit()

func _process(delta):
	move_type = move_types.DEFAULT
	
	if Input.is_action_pressed('shift'):
		move_type = move_types.STRAFE
	
	if Input.is_action_pressed('m2'):
		move_type = move_types.STRAFE
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if cam_center.rotation.y != 0:
			rotation.y = cam_center.global_rotation.y
			cam_center.rotation.y = 0
		if Input.is_action_pressed('m1'):
			move_type = move_types.MOUSE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_pressed('m1'):
		if (Time.get_unix_time_from_system() - m1_just_pressed >= 0.175 || (mouse_pos - m1_pressed_pos).length() >= 10) && !Input.is_action_pressed('m2'):
			m1_hold = true
		else:
			m1_hold = false

func _physics_process(delta):
	var jump_state = Vector2(Input.is_action_just_pressed('jump'), Input.is_action_pressed('jump'))
	velocity.y = movement.y_vel(self, jump_state, delta)
	
	var input_dir = Input.get_vector('left', 'right', 'forward', 'back')
	
	if move_type == move_types.DEFAULT:
		movement.rot(self, Vector3.UP, -input_dir.x * (key_turn_sens / 10), delta)
		if input_dir.x != 0 && !Input.is_action_pressed('m1'):
			center_cam()
		input_dir.x = 0
	elif move_type == move_types.MOUSE:
		input_dir.y = -1
	
	if auto_walk:
		input_dir.y = -1
	if input_dir.y > 0:
		input_dir *= 0.6
	
	var xz = movement.xz_vel(self, input_dir, move_type, delta)
	velocity.x = xz.x
	velocity.z = xz.y
	
	if !Input.is_action_pressed('m1') && xz != Vector2.ZERO:
		center_player()
	
	move_and_slide()

func center_cam():
	if abs(cam_center.rotation.y) > 0.01:
		cam_center.rotate_y(short_angle_dist(cam_center.rotation.y, 0) * snap_weight)
	else:
		cam_center.rotation.y = 0

func center_player():
	if abs(cam_center.rotation.y) > 0.01:
		rotation.y = rotation.y + (cam_center.rotation.y * snap_weight)
		cam_center.rotation.y -= (cam_center.rotation.y * snap_weight)
	else:
		rotation.y = cam_center.global_rotation.y
		cam_center.rotation.y = 0

func find_target():
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	
	params.collide_with_areas = true
	params.from = cam.global_position
	params.to = cam.project_position(mouse_pos, 100)
	params.collision_mask = 4
	
	var r = space_state.intersect_ray(params)
	if r:
		if r.collider.get_class() == 'targetable':
			var e = r.collider.get_parent()
			target = e
		else:
			target = ''
	else:
		target = ''
	
	gui.change_target(target)

func _add_component(node):
	components.append(node)
