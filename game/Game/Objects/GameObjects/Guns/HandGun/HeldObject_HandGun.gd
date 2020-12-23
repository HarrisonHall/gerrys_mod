extends HeldObject
class_name HeldObject_HandGun

export (PackedScene) var casing = null
export var initial_velocity = 10.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _init():
	._init()
	bullet_type = "BasicBullet"
	bspeed = 200
	bscale = .38


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _emit_casing():
	var new_casing = Game.make_obj("Casing")
	new_casing.transform = $Pivot/CasingSpawn.global_transform
	new_casing.mom = new_casing.transform.basis.z * initial_velocity
	new_casing.send_update()
