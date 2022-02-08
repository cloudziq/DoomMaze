extends KinematicBody


export var SPEED        = 18
export var ACCELERATION = 12
export var JUMP_SPEED   = 32
export var GRAVITY      = 1.2

export var mouse_sensitivity = 0.20

onready var head   = $Head
onready var camera = $Head/Camera

var velocity  = Vector3.ZERO




func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)




func _physics_process(delta):
	var direction = Vector3.ZERO
	var head_basis = head.get_global_transform().basis

	if Input.is_action_pressed("forward"):
		direction -= head_basis.z
	elif Input.is_action_pressed("backward"):
		direction += head_basis.z

	if Input.is_action_pressed("left"):
		direction -= head_basis.x
	elif Input.is_action_pressed("right"):
		direction += head_basis.x

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y += JUMP_SPEED

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	velocity.y -= GRAVITY
	velocity = velocity.linear_interpolate(direction * SPEED, ACCELERATION * delta)
	velocity = move_and_slide(velocity, Vector3.UP)




func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		camera.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, deg2rad(-80), deg2rad(80))
