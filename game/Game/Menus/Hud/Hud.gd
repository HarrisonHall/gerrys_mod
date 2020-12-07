extends Control


onready var Game = get_tree().get_current_scene()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	var p = Game.get_current_player()
	if p:
		$HBoxContainer/RightContainer/HealthContainer/HealthLabel.text = "Health: " + str(p.health_count())
		$HBoxContainer/RightContainer/AmmoContainer/AmmoLabel.text = "Ammo: " + str(p.ammo_count())
		
