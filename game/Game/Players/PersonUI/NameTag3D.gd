extends Spatial


var _name = "Bobbert"

onready var name_label = $Viewport/Control/Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(delta):
	if visible:
		if get_parent() == Game.get_current_player():
			visible = false

func set_name(n):
	_name = n
	name_label.text = _name
