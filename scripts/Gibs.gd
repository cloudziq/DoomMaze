extends Spatial


var gib   : RigidBody
var blood : KinematicBody
var gib_types   := 2
var blood_types := 2
var rect_offset := 4

var velocity




func _ready():
	var num   : int
	var speed := 1.1
	translation.y += 4
	scale *= .5

	#### CHOOSE ONE GIB TYPE
	num = randi() % gib_types
	for a in gib_types:
		var node = get_node("Gib"+ str(a+1))
		if a == num:
			gib = node
		else:
			node.queue_free()

	#### CHOOSE ONE BLOOD TYPE
	num = randi() % blood_types
	for a in blood_types:
		var node = get_node("Blood"+ str(a+1))
		if a == num:
			blood = node
		else:
			node.queue_free()


	gib.translation.x  += rand_range(-rect_offset, rect_offset)
	gib.translation.y  += rand_range(-rect_offset, rect_offset)
	gib.translation.z  += rand_range(-rect_offset, rect_offset)
	gib.rotation.y      = deg2rad(randi() % 360)
	gib.linear_velocity = (rotation * speed)

	blood.translation.x  += rand_range(-rect_offset, rect_offset)
	blood.translation.y  += rand_range(-rect_offset, rect_offset)
	blood.translation.z  += rand_range(-rect_offset, rect_offset)
	blood.rotation.y      = deg2rad(randi() % 360)
#	blood.linear_velocity = (rotation * speed)
	var rand_scale = rand_range(2, 6)
	blood.get_node("decal").scale = Vector3(rand_scale, rand_scale, 1)




func _physics_process(_delta):
	if not blood.is_on_floor():
		velocity = Vector3.DOWN * 0.2
		velocity = blood.move_and_collide(velocity)
	else:
		print("blabla")
