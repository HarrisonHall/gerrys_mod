extends HeldObject
class_name HeldObject_HandGun


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _init():
	._init()
	bullet_type = "BasicBullet"
	bspeed = 200


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
