extends KinematicBody


var pos = Vector3()
var mom = Vector3()
var rot = Vector3()
var gravity = Vector3(0, -30, 0)
var last_time = -1

var ground_friction = 6
var air_friction = 3

var push_amount = 7

var obj_type = "generic"

onready var Game = get_tree().get_current_scene()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func do_reparent():
	# TODO: generalize under Game
	if get_parent() != Game.get_node("Map/Objects"):
		var old_trans = get_global_transform()
		var get_similar_one = Game.get_node("Map/Objects").get_node(name)
		if get_similar_one != null:
			queue_free()
			return
		var old_parent = get_parent()
		old_parent.remove_child(self)
		Game.get_node("Map/Objects").add_child(self)
		set_global_transform(old_trans)

var just_collided = false
func _process(delta):
	if not can_update:
		do_reparent()
		can_update = true
	var get_collision = move_and_collide(mom*delta,true, true, true)
	if get_collision != null:
		var col_obj = get_collision.collider
		if col_obj is KinematicBody:
			var player_names = []
			for child in Game.get_node("Map/Players").get_children():
				player_names.append(child.name)
			if (col_obj.name in player_names) and col_obj.name != Game.username:
				pass
			else:
				var col_pos = col_obj.get_global_transform().origin
				var cur_pos = get_global_transform().origin
				mom += (cur_pos - col_pos)*push_amount
				if col_obj.name == Game.username:
					send_update()
	
	var move_vector = move_and_slide(mom, Vector3(0, 1, 0))
	mom = move_vector
	
	if is_on_floor():
		mom = mom - delta * ground_friction * mom.normalized()
		last_valid_pos = get_global_transform().origin
	else:
		mom = mom - delta * air_friction * mom.normalized()
		mom += gravity * delta


func send_update():
	if not can_update:
		return
	pos = get_global_transform().origin
	rot = get_rotation()
	print(OS.get_ticks_msec())
	Game.Web.request("update_info", {
		"username": Game.username,
		"update": {
			"objects": {
				name : {
					"position": [pos.x, pos.y, pos.z],
					"momentum": [mom.x, mom.y, mom.z],
					"rotation": [rot.x, rot.y, rot.z],
					"type": obj_type
				}
			}
		},
		"timestamp": OS.get_ticks_msec()
	})

var can_update = false
var last_timestamp = -1
func get_update(obj, timestamp):
	if not can_update:
		print("Can't update")
		return
	if timestamp <= last_timestamp:
		#print("Invalid timestamp")
		return
	print(obj)
	last_timestamp = timestamp
	rot = Vector3(obj["rotation"][0], obj["rotation"][1], obj["rotation"][2])
	mom = Vector3(obj["momentum"][0], obj["momentum"][1], obj["momentum"][2])
	pos = Vector3(obj["position"][0], obj["position"][1], obj["position"][2])
	
	var trans = get_global_transform()
	trans.origin = pos
	set_global_transform(trans)
	set_rotation(rot)

var last_valid_pos = Vector3()
func respawn():
	print("respawning")
	var trans = get_global_transform()
	trans.origin = last_valid_pos
	set_global_transform(trans)
	mom = Vector3()
