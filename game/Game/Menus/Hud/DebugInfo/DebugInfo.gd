extends Control


onready var fps_label = $fps_label


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("debug_on", self, "handle_debug")
	Events.connect("debug_off", self, "handle_debug")
	handle_debug()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		fps_label.text = str(Engine.get_frames_per_second())

func handle_debug():
	if Game.debug:
		visible = true
	else:
		visible = false
