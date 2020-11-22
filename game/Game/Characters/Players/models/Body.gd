extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#$AP.set_autoplay("walking")
	$AP.play("walking")
	print("set walking")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func walk():
	if $AP.current_animation != "walking":
		$AP.play("walking")

func stand():
	if $AP.current_animation != "standing":
		$AP.play("standing")

func shoot():
	if $AP.current_animation != "shooting":
		$AP.play("shooting")
