extends Spatial




func _ready():
	var rot = rotation ; rot.y += PI * 2
	$Tween.interpolate_property($key_item, "rotation",
		rotation, rot, 2,
		Tween.TRANS_LINEAR, 0)
	$Tween.start()




func player_collect():
	$ItemCollect.play()
	hide()
	yield($ItemCollect, "finished")
	queue_free()




func _on_Tween_completed():
	rotation = Vector3.ZERO
	_ready()
