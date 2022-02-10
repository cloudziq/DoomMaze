extends Spatial


export(PackedScene) var _mob ; var mob : KinematicBody

export var current_level = 1 ; var level
export var mob_amount    = 1 ; var max_mobs = 8


var mob_proximity_sound_delay : int
var test_camera := false




func _ready():
	randomize()
	window_prepare()
	set_process(false)
	set_process_input(false)
	$Sound/LevelMusic.play()




func _process(_delta):
	#### MOB PROXIMITY SOUND
	var pos1 = mob.translation
	var pos2 = $Player.translation
	var delay = pos1.distance_to(pos2) * 12
	if OS.get_system_time_msecs() > mob_proximity_sound_delay:
		mob_proximity_sound_delay = OS.get_system_time_msecs() + delay
		$Sound/MobProximity.play()




func _input(event):
	if current_level == 0 and event.is_action_pressed("test_camera"):
		test_camera = not test_camera
		if test_camera:
			$Player/Head/Camera.current = false
			$Player/Body.show()
			level.get_node("Camera").current = true
		else:
			$Player/Head/Camera.current = true
			$Player/Body.hide()
			level.get_node("Camera").current = false




func new_game():
	#### LOAD LEVEL:
	level = load("res://scenes/level_"+str(current_level) +".tscn").instance()
	var level_path = "level_"+str(current_level)
	add_child(level)

	#### CORRECT LEVEL OBJECT COORDINATES & HIDE SPAWN VISUAL MESHES
	get_node(level_path + "/GridMap").translation = Vector3(4, 0, -4)

	var node = get_node(level_path + "/PlayerSpawn")
	node.translation[0] += 4 ; node.translation[2] -= 4
	get_node(level_path + "/PlayerSpawn").hide()

	for index in max_mobs:
		var path = level_path + "/MobSpawn"+str(index+1)
		if get_node_or_null(path) != null:
			get_node(path).translation[0] += 4 ; get_node(path).translation[2] -= 4
			get_node(path).hide()

	## CORRECT LEVEL CAMERA IF IT EXISTS
	if get_node_or_null(level_path + "/Camera") != null:
		node = get_node(level_path + "/Camera")
		node.translation[0] += 4 ; node.translation[2] -= 4

	#### SET POSITION OF PLAYER AND MOBS
	$Player.translation = get_node(level_path + "/PlayerSpawn").translation
	$Player.rotation = get_node(level_path + "/PlayerSpawn").rotation

	var spawns_amount = 0
	for index in mob_amount:
		mob = _mob.instance() ; add_child(mob)
		var scale = 1 ; mob.scale = Vector3(scale, scale, scale)

		## USE ONLY AVAILABLE SPAWN POINTS
		var path
		var suffix = "/MobSpawn" + str(index+1)
		if get_node_or_null(level_path + suffix) != null:
			path = level_path + suffix
		else:
			if spawns_amount == 0 : spawns_amount = index
			path = level_path + "/MobSpawn"+str(randi() % spawns_amount + 1)
		mob.translation = get_node(path).translation
		mob.translation[1] += 2.4

	#### FINALISE
	$Player.on_new_game()
	set_process(true)
	set_process_input(true)




func game_over():
	level.queue_free()
	get_tree().call_group("enemy", "queue_free")
	set_process(false)
	set_process_input(false)
	test_camera = false
	yield(get_tree().create_timer(1), "timeout")
	get_tree().call_group("main_menu", "show")




func window_prepare():
	var display_size = OS.get_screen_size()
	var window_size = OS.window_size
	window_size.x *= 4 ; window_size.y *= 4

	if display_size.y <= window_size.y:
		var scale_ratio = window_size.y / (display_size.y - 100)
		window_size.x /= scale_ratio ; window_size.y /= scale_ratio

	OS.set_window_size(window_size)
	window_size.y += 80
	OS.set_window_position(display_size * .5 - window_size * .5)
