extends Spatial


var login_screen_pck = preload("res://Game/login/LoginScreen.tscn")


onready var Web = $Web



# Game vars
var username = "?"


# Called when the node enters the scene tree for the first time.
func _ready():
	# load login screen
	var login_screen = login_screen_pck.instance()
	$UI.add_child(login_screen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
