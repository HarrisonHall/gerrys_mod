extends Spatial


export var cooldown = 0
export var new_cooldown = 0.25
var bullet_type = "bullet"
onready var Game = get_tree().get_current_scene()
var bspeed = 16
var bscale = 1
var gun_ref = null

var inaccuracy = .1  # innacurrate (out of 1.0)

func _process(delta):
	cooldown -= delta
	if not has_ammo() and gun_ref:
		gun_ref.kill = true
		force_drop()

func use(t_inac=Vector3(), m_inac=Vector3()):
	if cooldown <= 0 and has_ammo():
		cooldown = new_cooldown
		$AnimationPlayer.play("shoot")
		var b = Game.make_obj(bullet_type, "")
		b.scale *= bscale
		if b:
			b.watching = true
			var player = Game.get_current_player()
			b.set_trans_mom(
				$ShootFrom.get_global_transform(), # Position to create bullet
				bspeed*(player.get_forward() - get_global_transform().origin).normalized() + m_inac*inaccuracy, # bullet momentum
				player.get_forward() + t_inac*inaccuracy # bullet target
			)
			b.queue_send_update = true
		if gun_ref:
			gun_ref.data["ammo"] -= 1

func get_update(obj, timestamp):
	if .get_update(obj, timestamp):
		return

func shoot_pos():
	return $ShootFrom.get_global_transform().origin

func has_ammo():
	if gun_ref:
		return gun_ref.data["ammo"] > 0
	return true

func force_drop():
	var p = Game.get_current_player()
	if p:
		p.soft_let_go()
	return
