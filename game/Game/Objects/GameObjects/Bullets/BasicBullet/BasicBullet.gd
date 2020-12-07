extends "res://Game/Objects/GameObjects/Bullets/Bullet.gd"


func _init():
	._init()
	obj_type = "BasicBullet"

func _on_Hitbox_body_entered(body):
	if body.name == "StaticBody":
		kill = true
		send_update()
