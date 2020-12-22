extends Camera


onready var Game = get_tree().get_root()


func _ready():
	reset_cross()
	Events.connect("viewport_changed", self, "reset_cross")

func reset_cross():
	var view = get_viewport()
	var width = view.size[0]
	var height = view.size[1]
	$CrossHair.set_margin(MARGIN_LEFT, width/2 - ($CrossHair.rect_size.x * $CrossHair.rect_scale.x)/2)
	$CrossHair.set_margin(MARGIN_TOP, height/2 - ($CrossHair.rect_size.y * $CrossHair.rect_scale.y)/2)

func get_forward():
	return $Forward.get_global_transform().origin
