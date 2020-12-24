extends Room
class_name EnemySpawner

var enemy_types = ["FleshBug"]


func _init():
	._init()
	obj_type = "BasicEnemySpawner"
	debug_color = Color(.79, .57, .21, 0.2)

func _ready():
	._ready()

func reseed():
	.reseed()
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
			enemy.rotate(Vector3.UP, rng.randf()*2*PI)
		else:
			print("Unable to spawn enemy")
