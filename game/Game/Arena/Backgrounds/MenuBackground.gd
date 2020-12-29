extends Spatial


onready var mv = $Cubes/MoveCube
var mv_start = null
var dis = 5
var cycle_time = 5
var ellapsed = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var background_color = Color(randf() / 2.0, randf() / 2.0, .5 + 0.5*randf())
	$WorldEnvironment.environment.background_color = background_color
	var cube_color = Color(randf() / 2.0, randf() / 2.0, .5 + 0.5*randf())
	for cube in $Cubes.get_children():
		cube.mesh.material.albedo_color = cube_color


func _process(delta):
	ellapsed += delta
	if mv_start == null:
		mv_start = mv.get_global_transform()
	var newtrans = mv_start
	newtrans.origin += Vector3(sin((ellapsed))*dis, 0, 0)
	mv.set_global_transform(newtrans)
