extends "res://Game/Objects/GameObjects/Guns/Gun.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _init():
	._init()
	obj_type = "Gun_BK47"
	gun_obj = "HeldObject_BK47"
	data["ammo"] = 20


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
