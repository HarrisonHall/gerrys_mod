extends "res://Game/Objects/GameObjects/GameObject.gd"


var turn_speed = PI
var max_ttl = 8
var r_seed = 0
var rng = RandomNumberGenerator.new()
var seeded = false

var possible_guns = ["Gun_AK47", "Gun_BK47", "Gun_HandGun", "Gun_BrainGun"]

func _init():
	._init()
	obj_type = "GunSpawner"
	data = {
		"ttl": 2,
		"has_item": false
	}
	connect("reparented", self, "reseed")

func _ready():
	._ready()
	$Helper.visible = false

func reseed():
	var spb = StreamPeerBuffer.new()
	rng.set_seed(Game.settings["serv_version"])
	var r = rng.randi() % 10000
	spb.data_array = (str(r) + get_name()).sha1_buffer()
	r_seed = spb.get_64()
	print("Seeded: ", r_seed)
	rng.set_seed(r_seed)
	#seeded = true
	var new_gun_type = possible_guns[rng.randi()%len(possible_guns)]
	var new_gun = Game.make_obj(new_gun_type, get_name() + "_" + str(rng.randi() % 1000))
	if new_gun:
		new_gun.set_global_transform($Spawn.get_global_transform())

func _process(delta):
	._process(delta)
	
	if data["ttl"] > 0 and not data["has_item"]:
		data["ttl"] -= delta


func _on_Hitbox_body_entered(player):
	if not data["has_item"]:
		return
	if player == Game.get_current_player():
		print("Give gun!")
		var gun_name = possible_guns[randi()%len(possible_guns)]
		var gun = Game.make_obj(gun_name)
		if gun and not player.is_holding:
			player.pick_up_gun(gun)
			gun.picked_up()
			data["has_item"] = false
			data["ttl"] = max_ttl
			send_update()
