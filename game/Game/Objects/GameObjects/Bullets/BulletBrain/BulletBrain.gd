extends "res://Game/Objects/GameObjects/Bullets/Bullet.gd"


func _init():
	._init()
	obj_type = "BasicBullet"
	gravity = Vector3(0, -5, 0)

func _on_Hitbox_body_entered(body):
	if body.name == "StaticBody":
		kill = true
		print("TODO: explode like a real brain would!")
		send_update()
