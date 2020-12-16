extends Spatial

func _ready():
	update()

func update():
	var trans = $Viewport/CamOffset.get_global_transform()
	trans.origin = get_global_transform().origin
	$Viewport/CamOffset.set_global_transform(get_global_transform())
