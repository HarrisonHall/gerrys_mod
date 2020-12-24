extends GameObject
class_name Room


# value of -1 means that the size is dynamic
var length = -1
var width = -1
var height = -1
var debug_color = Color(0, 0, 0, 0.5)

var rng = RandomNumberGenerator.new()
var r_seed = 0

func _init():
	._init()
	obj_type = "Room"
	data = {}
	gravity = Vector3(0, 0, 0)
	connect("reparented", self, "reseed")

func _ready():
	._ready()
	for mesh in $DebugMeshes.get_children():
		mesh.mesh.material.albedo_color = debug_color
		mesh.mesh.material.flags_transparent = true
	handle_debug()
	Events.connect("debug_on", self, "handle_debug")
	Events.connect("debug_off", self, "handle_debug")

func _process(delta):
	._process(delta)

func handle_debug():
	if Game.debug:
		$DebugMeshes.visible = true
	else:
		$DebugMeshes.visible = false

func set_length_width_height(l, w, h):
	length = l
	width = w
	height = h
	$DebugMeshes.scale = Vector3(w, h, l)

func reseed():
	var spb = StreamPeerBuffer.new()
	rng.set_seed(Game.settings["random_seed"])
	var r = rng.randi() % 10000
	spb.data_array = (str(r) + get_name() + str(r)).sha1_buffer()
	r_seed = spb.get_64()
	rng.set_seed(r_seed)

func get_random_position():
	var center = get_center_position()
	var xmod = -width*.8 + fmod(rng.randf()*100.0,(2.0*width))*.8
	var ymod = -length*.8 + fmod(rng.randf()*100.0,(2.0*length))*.8
	return Vector3(center.x+xmod, center.y - float(height)/2.0, center.z+ymod)

func get_center_position():
	return get_global_transform().origin
