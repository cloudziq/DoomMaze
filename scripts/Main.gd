extends Spatial



export(PackedScene) var _mob ; var mob : KinematicBody
export(PackedScene) var _gib


export var current_level = 1 ; var level
export var mob_amount    = 1


var ambient : Node


var mob_proximity_sound_delay : int
var test_camera := false
var key_spawn_num : int    #### HOLDS SPAWN NUM FOR KEY (FOR OVERHEAD VIEW DISPLAY)




func _ready():
	randomize()
	window_prepare()
	set_process(false) ; set_process_input(false)
	$Sound/LevelMusic.play()




func _process(_delta):
	#### MOB PROXIMITY SOUND
	var pos1 = mob.translation
	var pos2 = $Player.translation
	var delay = pos1.distance_to(pos2) * 12
	if OS.get_system_time_msecs() > mob_proximity_sound_delay:
		mob_proximity_sound_delay = OS.get_system_time_msecs() + delay
		$Sound/MobProximity.play()



func pppp():
	var sound = ambient.choose_ambient()
	print(sound)
	if sound != null:
		var file = "res://assets/sounds/ambience/"+ sound[0] +".ogg"
		var audio = AudioStreamPlayer.new() ; add_child(audio)
		audio.stream    = load(file)
		audio.volume_db = sound[1]
		audio.bus       = sound[2]
		audio.play() ; yield(audio, "finished") ; audio.queue_free()



func _input(event):
	if event.is_action_pressed("test_camera"):
		test_camera = not test_camera
		if test_camera:
			$Player/Head/Camera.current = false
			$Player/Body.show()
			level.get_node("OverheadCamera").current = true
			level.get_node("OverheadLight").show()
			level.get_node("CSGCombiner/Ceiling").hide()
			level.get_node("KeySpawns/Spawn" + str(key_spawn_num)).show()
		else:
			$Player/Head/Camera.current = true
			$Player/Body.hide()
			level.get_node("OverheadCamera").current = false
			level.get_node("OverheadLight").hide()
			level.get_node("CSGCombiner/Ceiling").show()
			level.get_node("KeySpawns/Spawn" + str(key_spawn_num)).show()

	if event.is_action_pressed("render_scale+"):
		window_prepare(OS.window_size * 1.1, true)
	elif event.is_action_pressed("render_scale-"):
		window_prepare(OS.window_size * .9,  true)




func new_game():
	mob_proximity_sound_delay = OS.get_system_time_msecs() + 4000
	ambient = Ambient.new()

	#### LOAD LEVEL:
	level = load("res://scenes/level_"+str(current_level) +".tscn").instance()
	var level_path = "level_"+str(current_level)
	add_child(level)

	#### CORRECT LEVEL OBJECTS COORDINATES & HIDE SPAWN VISUAL MESHES
	get_node(level_path + "/GridMap").translation = Vector3(4, 0, -4)

	var node = get_node(level_path + "/PlayerSpawn")
	node.translation[0] += 4 ; node.translation[2] -= 4
	get_node(level_path + "/PlayerSpawn").hide()

	for id in get_node(level_path + "/MobSpawns").get_children():
		id.translation[0] += 4 ; id.translation[2] -= 4
		id.hide()

	for id in get_node(level_path + "/KeySpawns").get_children():
		id.translation.x += 4 ; id.translation.z -= 4 ; id.hide()

	for index in get_node(level_path + "/Door").get_children():
		index.translation.x += 4 ; index.translation.z -= 4

	if get_node_or_null(level_path + "/OverheadCamera") != null:
		node = get_node(level_path + "/OverheadCamera")
		node.translation[0] += 4 ; node.translation[2] -= 4

	#### SET POSITION OF PLAYER AND MOBS
	$Player.translation = get_node(level_path + "/PlayerSpawn").translation
	$Player.rotation = get_node(level_path + "/PlayerSpawn").rotation

	var num_spawns = get_node(level_path + "/MobSpawns").get_child_count()
	for index in mob_amount:
		mob = _mob.instance() ; add_child(mob)
		var scale = 1 ; mob.scale = Vector3(scale, scale, scale)
		var path = level_path + "/MobSpawns/Spawn"+str(randi() % num_spawns + 1)
		mob.translation = get_node(path).translation
		mob.translation[1] += 2.2

	#### SPAWN A KEY
	var path = level_path + "/KeySpawns"
	key_spawn_num  = randi() % get_node(path).get_child_count() + 1
	path += "/Spawn"+ str(key_spawn_num)
	var key  = load("res://scenes/Key.tscn").instance() ; add_child(key)
	key.translation    = get_node(path).translation
	key.translation.y += .8

	#### FINALISE
	$Player.on_new_game()
	level.get_node("OverheadLight").hide()
	set_process(true) ; set_process_input(true)




func game_over():
	level.queue_free()
	ambient.queue_free()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("gibs",  "queue_free")
	get_tree().call_group("item",  "queue_free")
	set_process_input(false)
	test_camera = false
	yield(get_tree().create_timer(.4), "timeout")
	get_tree().call_group("main_menu", "show")




func spawn_gibs():
	for a in 10:
		var gib = _gib.instance() ; add_child(gib)
		gib.translation = $Player.translation




func window_prepare(size = OS.window_size, init := false):
	var display_size = OS.get_screen_size()
	var window_size = size
	if not init:
		window_size.x *= 4 ; window_size.y *= 4

	if display_size.y <= window_size.y:
		var scale_ratio = window_size.y / (display_size.y - 100)
		window_size.x /= scale_ratio ; window_size.y /= scale_ratio

	OS.set_window_size(window_size)
	window_size.y += 80
	OS.set_window_position(display_size * .5 - window_size * .5)
