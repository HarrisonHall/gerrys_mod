extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	var player = Game.get_current_player()
	if player:
		var health = player.data["health"]
		$VBoxContainer/ProgressBar.set_value(health)
