extends Spatial


var _name = "Bobbert"

onready var name_label = $Viewport/Control/Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_name(n):
	_name = n
	name_label.text = _name
