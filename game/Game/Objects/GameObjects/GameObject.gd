extends KinematicBody
class_name GameObject

var time_alive = 0
var pos = Vector3()
var mom = Vector3()
var rot = Vector3()
var gravity = Vector3(0, -30, 0)
var last_time = -1

var ground_friction = 6
var air_friction = 3
var MIN_MOM = 0.4

var can_collide = true
var push_amount = 7
var deleted = false
var created_online = false

var obj_type = "generic"

var data = {}
var kill = false
var queue_send_update = false


signal reparented

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func do_reparent():
	# TODO: generalize under Game
	if get_parent() != Game.Objects:
		var old_trans = get_global_transform()
		var name_should_be = Game.cur_arena + "_" + get_name().replace("@", "")
		if Game.Objects.has_node(name_should_be):
			deleted = true
			queue_free()
			return
		var old_parent = get_parent()
		old_parent.remove_child(self)
		Game.Objects.add_child(self)
		set_global_transform(old_trans)
		set_name(name_should_be)
	emit_signal("reparented")

var just_collided = false
func _process(delta):
	time_alive += delta
	if not can_update:
		do_reparent()
		can_update = true
	if deleted:
		return
	var get_collision = move_and_collide(mom*delta,true, true, true)
	if get_collision != null and can_collide:
		var col_obj = get_collision.collider
		if col_obj is KinematicBody:
			var player_names = []
			for child in Game.Players.get_children():
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
	
	# Zero friction
	if (mom.length() <= MIN_MOM):
		mom = Vector3(0, mom.y, 0)
		
	if queue_send_update:
		queue_send_update = false
		send_update()


func send_update():
	if not can_update:
		return false
	if Game.serv_version_just_changed:
		return false
	pos = get_global_transform().origin
	rot = get_rotation()
	Game.Web.request("update_info", {
		"username": Game.username,
		"update": {
			"objects": {
				name : {
					"position": [pos.x, pos.y, pos.z],
					"momentum": [mom.x, mom.y, mom.z],
					"rotation": [rot.x, rot.y, rot.z],
					"type": obj_type,
					"data": data,
					"kill": kill
				}
			}
		},
		"timestamp": OS.get_ticks_msec(),
		"settings": Game.settings
	})
	if kill: # TODO move?
		queue_free()
	return true

var can_update = false
var last_timestamp = -1
func get_update(obj, timestamp):
	if obj.get("kill", false):
		kill = true
		queue_free()
	if not can_update:
		return false
	if timestamp <= last_timestamp:
		return false
	last_timestamp = timestamp
	rot = Vector3(obj["rotation"][0], obj["rotation"][1], obj["rotation"][2])
	mom = Vector3(obj["momentum"][0], obj["momentum"][1], obj["momentum"][2])
	pos = Vector3(obj["position"][0], obj["position"][1], obj["position"][2])
	data = obj.get("data", data)
	
	var trans = get_global_transform()
	trans.origin = pos
	set_global_transform(trans)
	set_rotation(rot)
	return true

var last_valid_pos = Vector3()
func respawn():
	var trans = get_global_transform()
	trans.origin = last_valid_pos
	set_global_transform(trans)
	mom = Vector3()
