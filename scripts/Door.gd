extends Spatial



var new_pos1
var new_pos2
var open_time : int




func _ready():
	set_physics_process(false)




func open_door():
	new_pos1 = $DoorSide1.translation ; new_pos1.x -= 3.8
	new_pos2 = $DoorSide2.translation ; new_pos2.x += 3.8
	$DoorOpen.play()
	yield($DoorOpen, "finished")
	open_time = OS.get_system_time_msecs() + (6.4 * 1000)
	set_physics_process(true)




func _physics_process(_delta):
	$DoorSide1.translation = $DoorSide1.translation.linear_interpolate(new_pos1, .01)
	$DoorSide2.translation = $DoorSide2.translation.linear_interpolate(new_pos2, .01)

	if OS.get_system_time_msecs() < open_time:
		if not $DoorMove.playing:
			$DoorMove.play()
	else:
		$DoorMove.stop()
		$DoorOpened.play()
		set_physics_process(false)
