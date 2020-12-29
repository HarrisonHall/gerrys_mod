extends Enemy
class_name FleshBug

var bite_damage = 10
var MAX_ATTACK_COOLDOWN = 0.75
var attack_cooldown = 0

func _init():
	._init()
	obj_type = "FleshBug"
	data["health"] = 30

func _ready():
	._ready()
	follow_speed = 4

func _process(delta):
	._process(delta)
	attack_cooldown -= delta
	if attack_cooldown < 0 and len(attacking_players) > 0:
		attack_cooldown = MAX_ATTACK_COOLDOWN
		for player in attacking_players:
			player.take_neutral_damage(bite_damage)


func _on_VisionBox_body_entered(body):
	if body == Game.get_current_player():
		if data["ai_rate"] <= 0:
			data["ai_rate"] = AI_RESET_RATE
			data["follow_name"] = body.get_name()
			data["state"] = State.FOLLOW
			send_update()


var attacking_players = []
func _on_DamageBox_body_entered(body):
	if body == Game.get_current_player():
		var player = body
		attacking_players.append(player)

func _on_DamageBox_body_exited(body):
	if body == Game.get_current_player():
		var player = body
		if attacking_players.has(player):
			attacking_players.remove(attacking_players.find(player))
