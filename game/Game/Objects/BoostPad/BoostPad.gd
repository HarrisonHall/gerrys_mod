extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


const BOOST = 30
func _on_BoostUp_area_entered(area):
	if area.name == "SurfFeet":
		var player = area.get_parent()
		if player.name == Game.username:
			player.momentum.y = BOOST
