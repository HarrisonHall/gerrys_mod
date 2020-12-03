extends Spatial


export var cooldown = 0
export var new_cooldown = 0.25


func _ready():
	pass # Replace with function body.

func _process(delta):
	cooldown -= delta

func use():
	if cooldown <= 0:
		print("Using!")
		cooldown = new_cooldown

func get_update(obj, timestamp):
	if .get_update(obj, timestamp):
		return
