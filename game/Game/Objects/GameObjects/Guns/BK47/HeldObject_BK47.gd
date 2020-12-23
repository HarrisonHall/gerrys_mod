extends HeldObject
class_name HeldObject_BK47

export (PackedScene) var casing = null
export var initial_velocity = 10.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _init():
	._init()
	bspeed = 200
	bullet_type = "BasicBullet"
	bscale = .5


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _emit_casing():
	var new_casing = Resources.make_obj("Casing")
	new_casing.transform = $Pivot/CasingSpawn.global_transform
	new_casing.mom = new_casing.transform.basis.z * initial_velocity
	new_casing.send_update()
	
func _emit_flash():
	var new_flash = Resources.make_obj("Flash")
	new_flash.transform = $Pivot/MuzzleSpawn.global_transform
	new_flash.send_update()
