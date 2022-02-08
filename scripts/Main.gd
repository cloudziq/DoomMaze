extends Spatial




func _ready():
	$Player.translation = $levels/level_1/PlayerSpawn.translation
	$Mob.translation    = $levels/level_1/MobSpawn.translation
	$Mob2.translation    = $levels/level_1/MobSpawn2.translation
	$Mob3.translation    = $levels/level_1/MobSpawn3.translation
	$Mob4.translation    = $levels/level_1/MobSpawn4.translation
