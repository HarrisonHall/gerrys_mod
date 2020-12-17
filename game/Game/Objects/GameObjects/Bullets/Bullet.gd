extends "res://Game/Objects/GameObjects/GameObject.gd"

var watching = false
var damage = 1
var ttd = 3
var update_period = 10
var last_update = 0
var hit_own_player = false
var go_through_solid = true

func _init():
	._init()
	obj_type = "bullet"
	can_collide = false
	data = {}
	gravity = Vector3(0, 0, 0)
	ground_friction = 0
	air_friction = 0

func _process(delta):
	._process(delta)
	ttd -= delta
	if ttd <= 0:
		kill = true
	if watching:
		last_update -= delta
		if last_update <= 0:
			send_update()
			last_update = update_period

func set_trans_mom(trans, mom2, look):
	set_global_transform(trans)
	look_at(look, Vector3(0, 1, 0))
	mom = mom2

func send_update():
	var sent = .send_update()

func _on_Hitbox_area_entered(area):
	if area.get_name() == "HurtboxMid":
		if not watching:
			return
		var pers = area.get_parent()
		if not hit_own_player:
			if pers.get_name() == Game.username:
				return
		pers.take_damage(damage)
		#pers.send_data()
		kill = true
		send_update()
