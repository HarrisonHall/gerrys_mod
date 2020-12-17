extends Spatial


export var message_text = "PUT TEXT HERE - This is Debug text - "


# Called when the node enters the scene tree for the first time.
func _ready():
	$RScrollText3D.set_text(message_text)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
