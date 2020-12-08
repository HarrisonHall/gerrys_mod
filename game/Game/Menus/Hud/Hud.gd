extends Control


onready var Game = get_tree().get_current_scene()
onready var health_label = $HBoxContainer/RightContainer/HealthContainer/HealthLabel
onready var ammo_label = $HBoxContainer/RightContainer/AmmoContainer/AmmoLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	var p = Game.get_current_player()
	if p:
		health_label.text = "Health: " + str(p.health_count())
		if p.ammo_count() > 0:
			ammo_label.text = "Ammo: " + str(p.ammo_count())
		else:
			ammo_label.text = ""
		
