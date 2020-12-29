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
		ammo_label.set_text(str(player.ammo_count()) + "/" + str(player.ammo_count_max()))
		ammo_percent.max_value = player.ammo_count_max()
		ammo_percent.value = player.ammo_count()
