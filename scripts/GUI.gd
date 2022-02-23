extends CanvasLayer


signal new_game


var show_fps  := false




func _ready():
	$FPScounter.hide()
	$MarginContainer/PauseMenu.hide()




func _process(_delta):
	if show_fps:
		$FPScounter.text = str(Engine.get_frames_per_second())




func _input(event):
	if event.is_action_pressed("F1"):
		show_fps = not show_fps
		$FPScounter.show() if show_fps else $FPScounter.hide()\




func _on_StartButton_pressed():
	emit_signal("new_game")
	get_tree().call_group("main_menu", "hide")
