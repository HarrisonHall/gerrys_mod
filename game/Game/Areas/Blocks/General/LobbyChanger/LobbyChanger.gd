extends Spatial


export var lobby_mod = ""
onready var Game = get_tree().get_current_scene()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body == Game.get_current_player():
		if Game.singleplayer:
			Game.clear_gameplay()
			Game.load_arena(lobby_mod)
			Game.load_player()
			Game.get_current_player().respawn(Game.team)
		else:
			Game.change_lobby(Game.base_lobby, lobby_mod)

func set_lobby_mod(l):
	lobby_mod = l
