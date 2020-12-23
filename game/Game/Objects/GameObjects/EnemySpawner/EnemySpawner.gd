extends GameObject
class_name EnemySpawner

var enemy_types = ["FleshBug"]

export var width = 2
export var height = 2
export var debug = true

var rng = RandomNumberGenerator.new()
var r_seed = 0

onready var DebugMesh = $SpawnArea/CollisionShape/DebugMesh
onready var SpawnArea = $SpawnArea

func _init():
	._init()
	obj_type = "EnemySpawner"
	data = {
	}
	gravity = Vector3(0, 0, 0)
	connect("reparented", self, "reseed")

func _ready():
	._ready()
	if debug:
		DebugMesh.visible = true
	else:
		DebugMesh.visible = true
	SpawnArea.scale = Vector3(width, 1, height)

func get_random_position():
	var center = get_center_position()
	var xmod = -width*.8 + fmod(rng.randf()*100,(2*width))*.8
	var ymod = -height*.8 + fmod(rng.randf()*100,(2*height))*.8
	return Vector3(center.x+xmod, center.y, center.z+ymod)

func get_center_position():
	return get_global_transform().origin

func reseed():
	var spb = StreamPeerBuffer.new()
	rng.set_seed(Game.settings["serv_version"])
	var r = rng.randi() % 10000
	spb.data_array = (str(r) + get_name()).sha1_buffer()
	r_seed = spb.get_64()
	rng.set_seed(r_seed)
	
	#var max_enemies = (rng.randi() % Game.get_player_count()) + 1
	var max_enemies = (rng.randi() % 3)  # TODO? will offset 
	for i in range(max_enemies):
		var enemy = Resources.make_obj(
			enemy_types[rng.randi() % len(enemy_types)],
			get_name() + "_" + str(rng.randi() % 1000)
		)
		if enemy:
			var trans = enemy.get_global_transform()
			trans.origin = get_random_position()
			enemy.set_global_transform(trans)
		else:
			print("Unable to spawn enemy")

func set_width_height(w, h):
	width = w
	height = h
	SpawnArea.scale = Vector3(width, 1, height)
	
