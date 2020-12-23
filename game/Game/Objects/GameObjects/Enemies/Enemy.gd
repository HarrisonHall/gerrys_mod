extends GameObject
class_name Enemy


enum State {IDLE, FOLLOW}

var AI_RESET_RATE = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	collision_layer = 0b01
	collision_mask = 0b10
	can_collide = false
	gravity = Vector3(0, -10, 0)
	data["follow_name"] = ""
	data["ai_rate"] = 0
	data["state"] = State.IDLE
	data["health"] = 3


func _process(delta):
	._process(delta)
	if data["state"] == State.IDLE:
		queue_idle()
	if data["state"] == State.FOLLOW:
		queue_walk()
		walk_towards(delta)
	data["ai_rate"] -= delta
	if data["health"] <= 0:
		kill = true
		send_update()
		queue_free()


var follow_speed = 1
var MIN_FOLLOW_DISTANCE = 4
var MAX_FOLLOW_DISTANCE = 25
var rot_speed = 90  # deg/sec
var yrot = 0
func walk_towards(delta):
	if data["follow_name"] == "":
		return
	var follow_obj = Game.get_player(data["follow_name"])
	if follow_obj == null:
		return
	var mypos = get_global_transform().origin
	var newpos = follow_obj.get_global_transform().origin
	mypos.y = 0
	newpos.y = 0
	var walk_dir = (newpos - mypos)
	if walk_dir.length() < MIN_FOLLOW_DISTANCE:
		return
	if walk_dir.length() > MAX_FOLLOW_DISTANCE:
		follow_obj = null
		data["state"] = State.IDLE
	move_and_slide(follow_speed * walk_dir.normalized(), Vector3(0, 1, 0))
	mom = follow_speed * walk_dir.normalized()
	pos = get_global_transform().origin
	var RT = $RotationTween

	RT.stop_all()
	RT.remove_all()
	RT.interpolate_method(
		self, "easy_look_at", $Forward.get_global_transform().origin, get_global_transform().origin - walk_dir, delta
	)
	RT.start()
	
	if data["ai_rate"] <= 0 and Game.get_current_player() == follow_obj:
		send_update()
		data["ai_rate"] = AI_RESET_RATE

func easy_look_at(v):
	look_at(v, Vector3(0, 1, 0))

func queue_walk():
	if not has_node("AnimationPlayer"):
		return
	var ap = get_node("AnimationPlayer")
	if ap.has_animation("walk"):
		if ap.current_animation != "walk":
			ap.play("walk", 0.5)

func queue_idle():
	if not has_node("AnimationPlayer"):
		return
	var ap = get_node("AnimationPlayer")
	if ap.has_animation("idle"):
		if ap.current_animation != "idle":
			ap.play("idle", 0.5)

