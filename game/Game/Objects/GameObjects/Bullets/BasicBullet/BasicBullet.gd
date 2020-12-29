extends "res://Game/Objects/GameObjects/Bullets/Bullet.gd"
class_name BasicBullet


func _init():
	._init()
	obj_type = "BasicBullet"
	damage = 10

func _on_Hitbox_body_entered(body):
	if body.name == "StaticBody":
		kill = true
		send_update()
