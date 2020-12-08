extends Control


onready var Game = get_tree().get_current_scene()


# Called when the node enters the scene tree for the first time.
func _ready():
	refresh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func refresh():
	$MarginContainer/VBoxContainer/Sides/Info/Panel2/MapDescription.text = Game.arenas[Game.cur_arena]["description"]

func _on_Button_pressed():
	Game.load_player()
	Game.get_current_player().respawn(Game.team)
	Game.toggle_mode_menu(false)
	Game.toggle_pause_menu()
