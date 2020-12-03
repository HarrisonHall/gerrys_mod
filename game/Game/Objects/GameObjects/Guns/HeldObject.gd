extends Spatial


export var cooldown = 0
export var new_cooldown = 0.25
var bullet_type = "bullet"
onready var Game = get_tree().get_current_scene()


func _process(delta):
	cooldown -= delta

func use():
	if cooldown <= 0:
		cooldown = new_cooldown
		var b = Game.make_obj(bullet_type, "")
		if b:
			b.watching = true
			var player = Game.get_node("Map/Players/"+Game.username)
			b.set_trans_mom(get_global_transform(), 3*(player.get_forward() - get_global_transform().origin).normalized(), player.get_forward())
			b.queue_send_update = true

func get_update(obj, timestamp):
	if .get_update(obj, timestamp):
		return
