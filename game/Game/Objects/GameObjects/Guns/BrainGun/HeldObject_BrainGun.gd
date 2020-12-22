extends HeldObject
class_name HeldObject_BrainGun


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _init():
	._init()
	bspeed = 15
	bullet_type = "BulletBrain"
	bscale = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func use(t_inac=Vector3(), m_inac=Vector3()):
	.use(t_inac, m_inac)
