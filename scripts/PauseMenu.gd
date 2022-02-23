extends MarginContainer


var is_paused := false




func _ready():
	pass



func _input(event):
	if event.is_action_pressed("ui_cancel"):
		is_paused = not is_paused
		if is_paused:
			show() ; get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			hide() ; get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
