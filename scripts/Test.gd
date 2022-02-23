extends Node2D

var sound_data := {
	#FILENAME     LAST_USED, DELAY, DELAY RANDOMNESS
	"stormbolt1": [0, 90, 20],
	"stormbolt2": [0, 90, 30],
	"scary1":     [0, 60, 15],
	"scary2":     [0, 70, 25]
}

var ambient_delay : int


func play_ambient():
	var time = OS.get_system_time_secs()
#	var num_of_sounds = sound_data.size()
	var sounds = sound_data.duplicate()

	var new_sound = sounds.keys()[randi() % sounds.size()]
	while time < sounds[new_sound][0] and sounds.size() > 0:
		sounds.erase(new_sound)
		new_sound = sounds.keys()[randi() % sounds.size()]

#	print("result: "+str(new_sound))
	sound_data[new_sound][0] = time + sound_data[new_sound][1]



func _ready():
	randomize()
	play_ambient()

#### ROTATE SMOOTHLY?:
#var dir = transform.looking_at(target_vector, Vector3.UP)
#transform = transform.interpolate_with(dir, speed * delta)
