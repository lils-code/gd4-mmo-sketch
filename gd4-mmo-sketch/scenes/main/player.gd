extends CharacterBody3D

var movement = preload("res://scenes/main/movement.gd").new()

@onready var cam_center = $cam_center
@onready var arm = $cam_center/arm
@onready var cam = $cam_center/arm/camera
@onready var ray = $cam_center/arm/camera/ray

var sens = 1
var key_turn_sens = 0.45
var arm_len = 5

const rot_speed = 0.03
const snap_weight = 0.08

var prev_cap = false
var mouse_vel = Vector2.ZERO
var mouse_pos = Vector2.ZERO
var min_arm_len = 2
var max_arm_len = 7.5
var total_y_rot = 0

enum move_types {
	DEFAULT,
	STRAFE,
	MOUSE
}

var move_type = move_types.DEFAULT

var m1_just_pressed = 0
var m1_displacement = 0
var m1_hold = false

func short_angle_dist(from, to):
	var dif = fmod(to - from, PI * 2)
	return fmod(2 * dif, PI * 2) - dif

func _input(event):
	if event is InputEventMouseMotion:
		if move_type == move_types.DEFAULT:
			mouse_pos = event.global_position
		
		if Input.is_action_pressed('m2'):
			movement.rot(self, Vector3.UP, sens * event.relative.x / -750, 0)
		if m1_hold:
			cam_center.rotate(Vector3.UP, sens * event.relative.x / -330)
		if Input.is_action_pressed('m1') || Input.is_action_pressed('m2'):
			var y_rot = sens * event.relative.y / -330
			y_rot = clamp(total_y_rot + y_rot, -0.4 * PI, 0.1 * PI) - total_y_rot
			total_y_rot += y_rot
			
			cam_center.rotate(cam_center.transform.basis.x, y_rot)

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
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	if Input.is_action_just_released('m2'):
		Input.warp_mouse(mouse_pos)
	
	if Input.is_action_just_pressed('m1'):
		m1_just_pressed = 0
		m1_displacement = 0
	elif Input.is_action_pressed('m1'):
		m1_just_pressed += 1
		m1_displacement += sqrt(abs(Input.get_last_mouse_velocity().length()))
		
		if m1_just_pressed >= 25 || m1_displacement >= 100:
			if !Input.is_action_pressed('m2'):
				m1_hold = true
	elif Input.is_action_just_released('m1'):
		m1_hold = false
		if m1_just_pressed < 25 && m1_displacement < 100:
			if !Input.is_action_pressed('m2'):
				target()
	
	if (Input.is_key_pressed(KEY_ESCAPE)):
		get_tree().quit()

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

func target():
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.collide_with_areas = true
	params.from = cam.global_position
	params.to = cam.project_position(mouse_pos, 100)
	params.collision_mask = 4
	var r = space_state.intersect_ray(params)
	if r:
		if r.collider.get_class() == 'Area3D':
			print(r.collider.get_class())
		else:
			print('miss')
	else:
		print('miss')
