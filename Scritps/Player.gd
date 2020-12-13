extends KinematicBody

const WALK_SPEED := 10 # m/s
const JUMP_SPEED := 10 # m/s
const GROUND_ACCEL := 6 # (m/s)/(m/s)/s
const GROUND_DECEL := 12 # (m/s)/(m/s)/s
const AIR_ACCEL := 0.5 # (m/s)/(m/s)/s
const GRAVITY := 9.8 # m/s^2
const MOUSE_SENSITIVITY := 0.01 # rad/px

onready var rotate_y := $RotateY
onready var rotate_x := $RotateY/RotateX

var velocity := Vector3()
var target_velocity := Vector3()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var forward = 0
	var right = 0
	if Input.is_action_pressed("movement_forward"):
		forward += 1
	if Input.is_action_pressed("movement_backward"):
		forward -= 1
	if Input.is_action_pressed("movement_left"):
		right -= 1
	if Input.is_action_pressed("movement_right"):
		right += 1
	
	var view_basis = rotate_y.get_global_transform().basis
	target_velocity = (-view_basis.z * forward + view_basis.x * right).normalized() * WALK_SPEED
	
	var acceleration = (GROUND_ACCEL if velocity.dot(target_velocity) > 0 else GROUND_DECEL) if is_on_floor() else AIR_ACCEL
	
	velocity.y -= delta * GRAVITY
	velocity.x = lerp(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, acceleration * delta)
	
	if is_on_floor() and Input.is_action_just_pressed("movement_jump"):
		velocity.y = JUMP_SPEED
	
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
	print(velocity, velocity.length())

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_x.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		rotate_y.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

		rotate_x.rotation_degrees.x = clamp(rotate_x.rotation_degrees.x, -70, 70)
