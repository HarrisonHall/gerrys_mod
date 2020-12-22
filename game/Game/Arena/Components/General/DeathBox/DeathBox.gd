extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_area_entered(area):
	if area.get_name() == "Hitbox":
		if Game.username == area.get_parent().get_name():
			area.get_parent().respawn(Game.team)
