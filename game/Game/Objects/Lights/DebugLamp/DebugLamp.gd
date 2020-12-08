extends Spatial


export var color = Color(1.0, 1.0, 1.0)
export var energy = 1.0
export var light_range = 12.5


# Called when the node enters the scene tree for the first time.
func _ready():
	$OmniLight.light_color = color
	$OmniLight.omni_range = light_range
	$OmniLight.light_energy = energy


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
