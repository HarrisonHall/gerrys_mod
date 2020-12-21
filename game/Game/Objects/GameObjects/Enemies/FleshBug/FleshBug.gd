extends "res://Game/Objects/GameObjects/Enemies/Enemy.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	follow_speed = 4


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VisionBox_body_entered(body):
	if body == Game.get_current_player():
		if data["ai_rate"] <= 0:
			data["ai_rate"] = AI_RESET_RATE
			data["follow_name"] = body.get_name()
			data["state"] = State.FOLLOW
			send_update()
