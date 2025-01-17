extends GameObject
class_name Gun

var pick_up_timer = 0
var can_be_picked_up = true
var gun_obj = "HeldObject"


func _init():
	._init()
	gravity = Vector3(0, -10, 0)
	obj_type = "Gun"
	can_collide = false
	data = {
		"can_be_picked_up": true,
		"ammo": 10,
		"max_ammo": 10
	}

func _ready():
	._ready()

func _process(delta):
	pick_up_timer -= delta
	._process(delta)

func picked_up():
	print("Picked up")
	can_be_picked_up = false
	data["can_be_picked_up"] = false
	visible = false
	send_update()

func let_go(pos, new_mom=Vector3()):
	print("Let go")
	pick_up_timer = 2
	visible = true
	can_be_picked_up = true
	data["can_be_picked_up"] = true
	var trans = get_global_transform()
	trans.origin = pos
	mom = new_mom
	set_global_transform(trans)
	send_update()

func get_update(obj, timestamp):
	if .get_update(obj, timestamp):
		if can_be_picked_up != obj["data"].get("can_be_picked_up", can_be_picked_up):
			print(obj)
			if obj["data"]["can_be_picked_up"]:
				pick_up_timer = 2
				visible = true
			else:
				visible = false
			can_be_picked_up = obj["data"]["can_be_picked_up"]
		else:
			print("No change to gun: ", obj)

func send_update():
	print("Sending update for gun: can be picked up: ", data["can_be_picked_up"])
	.send_update()

func _on_Hitbox_area_entered2(area):
	if not can_be_picked_up:
		return
	if pick_up_timer > 0:
		return
	if area.get_parent().get_name() == Game.username:
		var pers = area.get_parent()
		if not pers.is_holding:
			pers.pick_up_gun(self)
			picked_up()
