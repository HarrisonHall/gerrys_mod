extends Spatial
class_name MazePlayerSpawner


export var width = 2
export var height = 2
export var debug = true

var created_online = false  # Doesn't matter

var rng = RandomNumberGenerator.new()
var r_seed = 0

onready var DebugMesh = $SpawnArea/CollisionShape/DebugMesh
onready var SpawnArea = $SpawnArea

func _init():
	pass

func _ready():
	if debug:
		DebugMesh.visible = true
	else:
		DebugMesh.visible = true
	SpawnArea.scale = Vector3(width, 1, height)
	rng.randomize()

func get_random_position():
	var center = get_center_position()
	var xmod = -width*.8 + fmod(rng.randf()*100,(2*width))*.8
	var ymod = -height*.8 + fmod(rng.randf()*100,(2*height))*.8
	return Vector3(center.x+xmod, center.y, center.z+ymod)

func get_center_position():
	return get_global_transform().origin

func set_width_height(w, h):
	width = w
	height = h
	SpawnArea.scale = Vector3(width, 1, height)
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
