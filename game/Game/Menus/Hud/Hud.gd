extends Control


onready var health_label = $HBoxContainer/RightContainer/HealthContainer/HealthLabel
onready var ammo_label = $HBoxContainer/RightContainer/AmmoContainer/AmmoLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_cross()
	Events.connect("viewport_changed", self, "reset_cross")

func _process(delta):
	var p = Game.get_current_player()
	if p:
		health_label.text = "Health: " + str(p.health_count())
		if p.ammo_count() > 0:
			ammo_label.text = "Ammo: " + str(p.ammo_count())
		else:
			ammo_label.text = ""

func reset_cross():
	var view = get_viewport()
	var width = view.size[0]
	var height = view.size[1]
	$CrossHair.set_margin(MARGIN_LEFT, width/2 - ($CrossHair.rect_size.x * $CrossHair.rect_scale.x)/2)
	$CrossHair.set_margin(MARGIN_TOP, height/2 - ($CrossHair.rect_size.y * $CrossHair.rect_scale.y)/2)
