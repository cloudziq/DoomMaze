extends KinematicBody


signal game_over


export var SPEED        = 18
export var ACCELERATION = 12
export var JUMP_SPEED   = 42
export var GRAVITY      = 2

export var mouse_sensitivity = 0.20

onready var head   = $Head
onready var camera = $Head/Camera


var footstep = [
	preload("res://assets/sounds/footsteps/footstep1.ogg"),
	preload("res://assets/sounds/footsteps/footstep2.ogg"),
	preload("res://assets/sounds/footsteps/footstep3.ogg"),
	preload("res://assets/sounds/footsteps/footstep4.ogg")
]

var jump = [
	preload("res://assets/sounds/jump/jump1.ogg"),
	preload("res://assets/sounds/jump/jump2.ogg"),
	preload("res://assets/sounds/jump/jump3.ogg"),
	preload("res://assets/sounds/jump/jump4.ogg")
]

var death = [
	preload("res://assets/sounds/player_death/death1.ogg"),
	preload("res://assets/sounds/player_death/death2.ogg"),
	preload("res://assets/sounds/player_death/death3.ogg"),
	preload("res://assets/sounds/player_death/death4.ogg"),
	preload("res://assets/sounds/player_death/death5.ogg")
]


var velocity       := Vector3.ZERO
var last_direction := Vector3.ZERO




func _ready():
	in_main_menu()




func _physics_process(delta):
	var direction = Vector3.ZERO
	var head_basis = head.get_global_transform().basis

	if is_on_floor():
		if Input.is_action_pressed("forward"):
			direction -= head_basis.z
		elif Input.is_action_pressed("backward"):
			direction += head_basis.z

		if Input.is_action_pressed("left"):
			direction -= head_basis.x
		elif Input.is_action_pressed("right"):
			direction += head_basis.x

		if Input.is_action_pressed("jump"):
			velocity.y += JUMP_SPEED
			$Sound/Jump.stream = jump[randi() % jump.size()]
			$Sound/Jump.play()

		if direction != Vector3.ZERO:
			direction = direction.normalized()
			if not $Sound/Footsteps.playing:
				$Sound/Footsteps.stream = footstep[randi() % footstep.size()]
				$Sound/Footsteps.play()
		last_direction = direction
	else:
		direction = last_direction * .6

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




func in_main_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_physics_process(false)
	set_process_input(false)
	$Body.hide()
	$Head/Camera.current = true
	hide()




func on_new_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$MobDetector/CollisionShape.disabled = false
	set_physics_process(true)
	set_process_input(true)
	collision_layer = 1
	show()




func _on_MobDetector_body_entered(_body):
	owner.get_node("Mob").post_player_kill()
	$MobDetector/CollisionShape.disabled = true
	$Sound/Death.stream = death[randi() % death.size()]
	$Sound/Death.play()
	in_main_menu()
	collision_layer = 0
	yield(get_tree().create_timer(3), "timeout")
	$Head.rotation        = Vector3.ZERO
	$Head/Camera.rotation = Vector3.ZERO
	emit_signal("game_over")

