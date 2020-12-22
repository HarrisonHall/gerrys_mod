extends "res://Game/Objects/GameObjects/GameObject.gd"
class_name Casing

func _init():
	._init()
	gravity=Vector3(0,-10,0)

func _on_Lifetime_timeout():
	queue_free()
