extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Size ", get_viewport().size, " ", get_viewport().get_visible_rect().size)
	var width = get_viewport().size[0]
	var height = get_viewport().size[1]
	$CrossHair.set_margin(MARGIN_LEFT, width/2 - ($CrossHair.rect_size.x * $CrossHair.rect_scale.x)/2)
	$CrossHair.set_margin(MARGIN_TOP, height/2 - ($CrossHair.rect_size.y * $CrossHair.rect_scale.y)/2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_forward():
	return $Forward.get_global_transform().origin
