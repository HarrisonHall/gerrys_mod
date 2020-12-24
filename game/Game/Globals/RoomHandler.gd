extends Node


# Map of rooms by size, room[l][w][h] -> list of rooms with the given lenght, 
# width, and height in in-game units
var rooms_by_size = {}
var dynamic_rooms = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
