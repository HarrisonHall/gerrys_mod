extends Spatial

export var boost_strength = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BoostUp_area_entered(area):
	if area.name == "SurfFeet":
		var player = area.get_parent()
		if player == Game.get_current_player():
			player.momentum.y = boost_strength
