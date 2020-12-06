extends Control


onready var SessionInfo = $Margin/Menu/LeftHalf/SessionInfo
onready var ServerInfo = $Margin/Menu/LeftHalf/ServerInfo
onready var SettingsScreen = $Margin/Menu/LeftHalf/SettingsScreen
onready var ServerLogin = $Margin/Menu/RightHalf/ServerLogin
onready var ModMenu = $Margin/Menu/RightHalf/ModMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ExitButton_pressed():
	get_tree().quit()
