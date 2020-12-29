extends Bullet
class_name BulletBrain


func _init():
	._init()
	obj_type = "BasicBullet"
	gravity = Vector3(0, -5, 0)
	damage = 50

func _on_Hitbox_body_entered(body):
	if body.name == "StaticBody":
		kill = true
		print("TODO: explode like a real brain would!")
		send_update()
