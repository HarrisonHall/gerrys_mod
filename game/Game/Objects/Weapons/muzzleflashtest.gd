extends "res://Game/Objects/GameObjects/GameObject.gd"

func _init():
	._init()
	gravity=Vector3(0,0,0)

func _on_Lifetime_timeout():
	queue_free()
