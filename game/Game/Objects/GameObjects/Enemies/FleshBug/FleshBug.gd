extends Enemy
class_name FleshBug


func _ready():
	._ready()
	follow_speed = 4


func _on_VisionBox_body_entered(body):
	if body == Game.get_current_player():
		if data["ai_rate"] <= 0:
			data["ai_rate"] = AI_RESET_RATE
			data["follow_name"] = body.get_name()
			data["state"] = State.FOLLOW
			send_update()
