extends GameObject
class_name GunSpawner


onready var turner = $Base/Turner
var turn_speed = PI
var max_ttl = 8

var possible_guns = ["Gun_AK47","Gun_BK47", "Gun_HandGun", "Gun_BrainGun"]

func _init():
	._init()
	obj_type = "GunSpawner"
	data = {
		"ttl": 2,
		"has_item": false
	}

func _process(delta):
	._process(delta)
	
	if data["ttl"] > 0 and not data["has_item"]:
		data["ttl"] -= delta
		turner.visible = false
	if data["ttl"] <= 0:
		data["has_item"] = true
	if data["has_item"]:
		turner.visible = true
		turner.rotate(Vector3(0, 1, 0), delta*turn_speed)


func _on_Hitbox_body_entered(player):
	if not data["has_item"]:
		return
	if player == Game.get_current_player():
		print("Give gun!")
		var gun_name = possible_guns[randi()%len(possible_guns)]
		var gun = Resources.make_obj(gun_name)
		if gun and not player.is_holding:
			player.pick_up_gun(gun)
			gun.picked_up()
			data["has_item"] = false
			data["ttl"] = max_ttl
			send_update()
