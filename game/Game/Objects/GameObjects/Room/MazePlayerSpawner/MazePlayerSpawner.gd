extends Room
class_name MazePlayerSpawner


onready var DebugMesh = $SpawnArea/CollisionShape/DebugMesh
onready var SpawnArea = $SpawnArea

func _init():
	._init()
	obj_type = "MazePlayerSpawner"
	debug_color = Color(.14, .34, .67, 0.2)

func send_update():
	return

func set_length_width_height(l, w, h):
	.set_length_width_height(l, w, h)
	var arena = Game.get_arena()
	if arena:
		print("Moving spawn and cam")
		var spawn = arena.get_node("Spawn/1")
		var trans = spawn.get_global_transform()
		trans.origin = get_random_position()
		spawn.set_global_transform(trans)
		var cam = arena.get_node("GameCamera")
		var new_trans = cam.get_global_transform()
		new_trans.origin = $CamPosition.get_global_transform().origin
		cam.set_global_transform(new_trans)
		cam.rotate(Vector3(1, 0, 0), -PI/2)
	else:
		print("Unable to get arena")
