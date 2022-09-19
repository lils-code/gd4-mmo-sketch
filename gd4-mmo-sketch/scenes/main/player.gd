extends CharacterBody3D

const speed = 6
const accel = 0.6

var curaccel = 0

const gravity = 19

const jumpvel = 15
const jumplen = 0.25
const jumpfalloff = 0.2
const jumpovershoot = 0.2

var curjumplen = 0
var jump = false

var movestrafe = false
var prevcap = false
var mousevel = Vector2.ZERO
var mousepos = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		mousevel = event.velocity

func _physics_process(delta):
	rot(delta)

	y_vel(delta)

	xz_vel(delta)
	
	move_and_slide()

func rot(delta):
	var rot = Vector2.ZERO
	movestrafe = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	
	#rot.x = InputEventMouseMotion
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MASK_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_MASK_RIGHT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		prevcap = true
		
		print(mousevel)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		if prevcap:
			Input.warp_mouse(mousepos)
			prevcap = false
			
		mousepos = get_viewport().get_mouse_position()

func y_vel(delta):
	var flrtest = is_on_floor()
	
	if flrtest:
		jump = false
		if Input.is_action_just_pressed('jump'):
			jump = true
			curjumplen = 0
			velocity.y = jumpvel
	else:
		if jump and not Input.is_action_pressed('jump'):
			jump = false
	
	if jump:
		if curjumplen < jumplen:
			velocity.y = jumpvel - ((jumpvel * pow(curjumplen, jumpfalloff)) / pow(jumplen + jumpovershoot, jumpfalloff))
		else:
			jump = false
		
		curjumplen += delta
	
	if not flrtest and not jump:
		if Input.is_action_just_released('jump'):
			velocity.y *= 0.66
		
		velocity.y -= gravity * delta

func xz_vel(delta):
	var inputdir = Input.get_vector('left', 'right', 'forward', 'back')
	var dir = (transform.basis * Vector3(inputdir.x, 0, inputdir.y)).normalized()
	
	if dir == Vector3.ZERO:
		curaccel -= accel
	else:
		curaccel += accel
	
	curaccel = clamp(curaccel, 0, speed)
	velocity.x = dir.x * curaccel
	velocity.z = dir.z * curaccel
