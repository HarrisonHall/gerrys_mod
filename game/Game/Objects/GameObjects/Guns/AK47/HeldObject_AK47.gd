extends HeldObject
class_name HeldObject_AK47


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _init():
	._init()
	bspeed = 100
	bullet_type = "BasicBullet"
	bscale = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
