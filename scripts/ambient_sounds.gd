extends Node
class_name Ambient


var sound_data := {
	#FILENAME     LAST_USED, DELAY, DELAY RANDOMNESS, VOLUME, AUDIO_BUS
	"stormbolt1": [0, 90, 20, 0, "Distant"],
	"stormbolt2": [0, 90, 30, -2, "Distant"],
	"scary1":     [0, 60, 15, -4, "maze_reverb"],
	"scary2":     [0, 70, 25, -4, "maze_reverb"]
}




func _init():
	var time = OS.get_system_time_secs()

	for i in sound_data.keys():
		sound_data[i][0] = time + sound_data[i][2] / 2




func choose_ambient():
	var time := OS.get_system_time_secs()
	var sound_name = sound_data.keys()[randi() % sound_data.size()]
	var sound_vol = sound_data[sound_name][3]
	var sound_bus = sound_data[sound_name][4]

	if time > sound_data[sound_name][0]:
		var val = sound_data[sound_name][2]
		var randomness = rand_range(-val, val)
		sound_data[sound_name][0] = time + sound_data[sound_name][1] + randomness
		return [sound_name, sound_vol, sound_bus]
	else:
		return null
