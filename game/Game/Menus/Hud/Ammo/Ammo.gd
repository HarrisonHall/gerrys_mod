extends Control


var current_ammo = 0
var max_ammo = 0

onready var ammo_label = $VBoxContainer/AmmoLabel
onready var ammo_percent = $VBoxContainer/HBoxContainer/AmmoPercent

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var player = Game.get_current_player()
	if player:
		var max_value = player.ammo_count_max()
		var value = player.ammo_count()
		ammo_label.set_text(str(value) + "/" + str(max_value))
		if max_value == 0:
			ammo_percent.max_value = 1
		else:
			ammo_percent.max_value = max_value
		ammo_percent.value = value
