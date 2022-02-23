extends StaticBody


export(PackedScene) var _gib


var num_gibs = 20


func _ready():
	randomize()
	for a in num_gibs:
		var gib = _gib.instance() ; add_child(gib)
