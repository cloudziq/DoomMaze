extends KinematicBody


export var SPEED                      := 18.0
export var SPEED_CHASE_MULTIPLIER     := 3.0
export var SPEED_POST_KILL_MULTIPLIER := 1.0


var velocity = Vector3.ZERO
var target_vector
var rays := [["ray_front", 1], ["ray_left", 2], ["ray_right", 4]]

var last_coords     := [0, 0]
var is_wander       := true
var post_chase_init := true
var collide_state   := 0


enum states {WANDER, CHASE, POST_CHASE}
var STATE = states.WANDER




func _ready():
	set_physics_process(false)
	yield(get_tree().create_timer(.001), "timeout")
	set_physics_process(true)




func _physics_process(_delta):
	var speed :  int
	var angle := 0
	var direction = Vector3.ZERO
	var basis = get_global_transform().basis
	var x: int = round(translation[0])
	var z: int = round(translation[2])

	#### SHOT RAY IN PLAYER DIRECTION TO DETERMINE IF IT IS ON VIEW
	var pos = get_parent().get_node("Player").translation
	$ray_to_player.look_at(pos, Vector3.UP)

	if $ray_to_player.is_colliding():
		var collider_name = $ray_to_player.get_collider().name
		match collider_name:
			"Player":
				if collide_state < 5:  collide_state += 1
			_:
				if collide_state > -5: collide_state -= 1

	match STATE:
		states.WANDER:
			if collide_state == 5:
				STATE = states.CHASE
				$chase.play()
			speed = SPEED * SPEED_POST_KILL_MULTIPLIER

			if x % 8 == 0 and z % 8 == 0 and (last_coords[0] != x or last_coords[1] != z):
				angle = check_rays()
				last_coords = [x, z]

			if angle != 0:
				rotate_y(deg2rad(angle))
			else:
				move_forward(direction, speed, basis.z)

		states.CHASE:
			if collide_state == -5: STATE = states.POST_CHASE
			speed = SPEED * SPEED_CHASE_MULTIPLIER
			look_at(pos, Vector3.UP)
			rotate_object_local(Vector3.UP, PI)
			move_forward(direction, speed, basis.z)

		states.POST_CHASE:
			if post_chase_init:
				var tx = stepify(translation[0], 8)
				var tz = stepify(translation[2], 8)
				target_vector = Vector3(tx, translation[1], tz)
				post_chase_init = false

			look_at(target_vector, Vector3.UP)
			rotate_object_local(Vector3.UP, PI)
			speed = SPEED * .5

			if translation.distance_to(target_vector) <= 1:
				translation = target_vector
				last_coords = [9999,9999]
				rotation= Vector3.ZERO
				STATE = states.WANDER
				post_chase_init = true
			else:
				move_forward(direction, speed, basis.z)




func move_forward(direction, speed, basis):
	direction += basis
	velocity = direction * speed
	velocity = move_and_slide(velocity, Vector3.UP)




func check_rays():
	var angle  := 0
	var angles := []
	var value  := 0

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

	return angle




func post_player_kill():	#### CALLED FROM PLAYER SCRIPT
	STATE = states.POST_CHASE
	SPEED_POST_KILL_MULTIPLIER = .4




func _on_MobCollider_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	rotate_y(deg2rad(180))
#	last_coords = [9999, 9999]
