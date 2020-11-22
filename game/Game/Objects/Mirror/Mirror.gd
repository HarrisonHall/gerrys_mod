extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	var trans = $Viewport/CamOffset.get_global_transform()
	trans.origin = get_global_transform().origin
	#$Viewport/CamOffset.set_global_transform(trans)
	$Viewport/CamOffset.set_global_transform(get_global_transform())
