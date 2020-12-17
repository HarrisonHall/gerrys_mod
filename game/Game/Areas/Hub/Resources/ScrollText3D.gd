extends Spatial

export var text = "DEBUG TEXT: This is a test message!"
export var scroll_speed = 80
export var alpha = 1.0

onready var SC = $Viewport/Control/ScrollContainer
onready var CON = $Viewport/Control/ScrollContainer/HBoxContainer

var scroll_val = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var label = CON.get_children()[0]
	label.text = text
	var new_label = CON.get_children()[0].duplicate()
	CON.add_child(new_label)
	$MeshInstance.mesh.material.albedo_color.a = alpha

func set_text(t):
	for child in CON.get_children():
		child.set_text(t)
	text = t

func _process(delta):
	scroll_val += delta * scroll_speed
	SC.set_h_scroll(int(scroll_val))
	#print(SC.scroll_horizontal)
	if SC.get_h_scroll() >= CON.get_children()[0].margin_right:
		#print("Completed iteration")
		scroll_val = 0
		SC.set_h_scroll(0)
#	if int(scroll_val) > SC.get_scroll_horizontal():
#		var new_label = CON.get_children()[0].duplicate()
#		CON.add_child(new_label)
