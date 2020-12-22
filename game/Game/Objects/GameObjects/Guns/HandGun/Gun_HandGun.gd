extends Gun
class_name Gun_HandGun


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _init():
	._init()
	obj_type = "Gun_HandGun"
	gun_obj = "HeldObject_HandGun"

#Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
