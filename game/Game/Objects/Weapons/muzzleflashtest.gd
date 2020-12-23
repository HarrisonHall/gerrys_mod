extends GameObject
class_name MuzzleFlash

func _init():
	._init()
	gravity=Vector3(0,0,0)

func _on_Lifetime_timeout():
	queue_free()
