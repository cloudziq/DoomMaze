extends KinematicBody


export var SPEED = 40


var velocity   = Vector3.ZERO
var rays := [["ray_front", 1], ["ray_left", 2], ["ray_right", 4]]
var allow_turn_to_side := true

var last_coords := [0, 0]




func _ready():
	set_physics_process(false)
	yield(get_tree().create_timer(.001), "timeout")
	set_physics_process(true)



func _physics_process(delta):
	var angle := 0
	var direction = Vector3.ZERO
	var basis = get_global_transform().basis
	# warning-ignore:narrowing_conversion
	var x: int = round(translation[0])
	# warning-ignore:narrowing_conversion
	var z: int = round(translation[2])


	if x % 8 == 0 and z % 8 == 0 and (last_coords[0] != x or last_coords[1] != z):
		angle = check_rays()
		last_coords = [x, z]

	if angle != 0:
#		rotation = rotation.linear_interpolate(direction.angle_to(), 1)
		rotate_y(deg2rad(angle))
	else:
		direction += basis.z

		velocity = direction * SPEED
		velocity = move_and_slide(velocity, Vector3.UP)




#func check_rays():
#	var angle
#	var value := 0
#
#	for a in rays:
#			if not get_node(a[0]).is_colliding():
#				value += a[1]
#	match value:
#		2: angle = 90
#		4: angle = -90
#		6: angle = 90 if randf() > .5 else -90
#		0: angle = 180
#
#	return angle




func check_rays():
	var angle  := 0
	var angles := []
	var value  := 0

#	var collider = $ray_front.get_collider()
#		angle = 180
#	if $ray_front.is_colliding() and $ray_front.get_collider().
	print($ray_front.get_collider())

	for a in rays:
		if not get_node(a[0]).is_colliding():
			value += a[1]

	match value:
		0: angle = 180
		1: angle = 0
		2: angle = 90
		4: angle = -90
		3:
			angles = [0, 90]
			angle = angles[randi() % 2]
		5:
			angles = [0, -90]
			angle = angles[randi() % 2]
		6:
			angles = [-90, 90]
			angle = angles[randi() % 2]
		7:
			angles = [0, -90, 90]
			angle = angles[randi() % 3]

#	allow_turn_to_side = false

#	if not allow_turn_to_side:
#		if $ray_left.is_colliding() and $ray_right.is_colliding():
#			allow_turn_to_side = true

	return angle

