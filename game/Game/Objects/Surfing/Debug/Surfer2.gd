extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass




func _on_SurfArea_area_entered(area):
	if area.name == "SurfFeet":
		area.get_parent().surf_depth2 += 1

func _on_SurfArea_area_exited(area):
	if area.name == "SurfFeet":
		area.get_parent().surf_depth2 -= 1
