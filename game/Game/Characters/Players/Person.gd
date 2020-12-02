extends KinematicBody


var momentum = Vector3()
var gravity = Vector3(0, -30, 0)
var movement_momentum = 80
var crouch_momentum = 40
var ground_friction = 6

var CAM_SENSITIVITY = .3

const MAX_SPEED = 100
const MIN_MOM = 0.4
const MIN_WALK = 0.5

# Jumping
const MAX_JUMP_TIME = 1
const JUMP_MOM = 25
const INIT_JUMP_MOM = 10
var jump_time = 0

var Game = null

# surfing
var surf_depth = 0
var surf_depth2 = 0
const SURF_JUMP_FACTOR = 0.3

# crouching
var is_crouching = false

# sliding
var slide_time = 0
var SLIDE_MOM_FRAC = 2
var slide_friction = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	Game = get_tree().get_current_scene()
	set_model("seagal")

var runtime = 0

var is_vis = true
func _process(delta):
	if Game.username == name and is_vis:
		make_camera_current()
		#$Model/Body.make_invisible()
		is_vis = false
	elif Game.username != name and not is_vis:
		#$Model/Body.make_visible()
		is_vis = true
	
	# Movement
	if name == Game.username:
		process_movement(delta)
	move_player(delta)
	
	# Animations
	process_animations(delta)

func _input(event):
	if Game.menu_up:
		return
	if name != Game.username:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Move camera
		$CameraHinge.rotate_z(-deg2rad(event.relative.y * CAM_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * CAM_SENSITIVITY * -1))

		var camera_rot = $CameraHinge.rotation_degrees
		camera_rot.z = clamp(camera_rot.z, -110, 110)
		$CameraHinge.rotation_degrees = camera_rot
		update_bones()

func process_movement(delta):
	if Game.menu_up:
		return
	if slide_time == 0:
		var mom_mod = movement_momentum
		if is_crouching:
			mom_mod = crouch_momentum
		if Input.is_action_pressed("gm_left"):
			momentum += mom_mod * delta * get_transform().basis.xform(Vector3(0, 0, -1))
		if Input.is_action_pressed("gm_right"):
			momentum += mom_mod * delta * get_transform().basis.xform(Vector3(0, 0, 1))
		if Input.is_action_pressed("gm_up"):
			momentum += mom_mod * delta * get_transform().basis.xform(Vector3(1, 0, 0))
		if Input.is_action_pressed("gm_down"):
			momentum += mom_mod * delta * get_transform().basis.xform(Vector3(-1, 0, 0))
	if Input.is_action_pressed("gm_slide") and surf_depth <= 0 and surf_depth2 <= 0:
		slide_time += delta
	else:
		slide_time = 0
		if Input.is_action_pressed("gm_crouch"):
			is_crouching = true
		else:
			is_crouching = false
	if Input.is_action_pressed("gm_jump"):
		#if $FNormCast.is_colliding():
		if surf_depth > 0 or surf_depth2 > 0:
			momentum.y += momentum.normalized().length() * SURF_JUMP_FACTOR
			jump_time = MAX_JUMP_TIME
		elif slide_time > 0 and is_on_floor():
			momentum *= SLIDE_MOM_FRAC
			momentum.y = INIT_JUMP_MOM
			jump_time = MAX_JUMP_TIME
		elif is_on_floor():
			jump_time = MAX_JUMP_TIME
			momentum.y = INIT_JUMP_MOM
		elif not is_on_ceiling() and jump_time > 0:
			jump_time -= delta
			momentum += JUMP_MOM * (jump_time/MAX_JUMP_TIME) * delta * get_transform().basis.xform(Vector3(0, 1, 0))
	else:
		jump_time = 0

func move_player(delta):
	if name == Game.username or (len(pos_buffer) == 0 and not $RemoteMovement.is_active()):
		# Add gravity
		momentum += gravity*delta
		
		# Max speed
		if (momentum.length() > MAX_SPEED):
			momentum = momentum.normalized() * MAX_SPEED
		
		# Move with momentum
#		var snap = -$FNormCast.get_collision_normal()
#		if $FNormCast.is_colliding() and momentum.y <= 0:
#			var move_vector = move_and_slide_with_snap(momentum, snap, Vector3(0, 1, 0), true, 4, 0.785398)
#			momentum = move_vector
#		else:
#			var move_vector = move_and_slide(momentum, Vector3(0, 1, 0))
#			momentum = move_vector
		var move_vector = move_and_slide(momentum, Vector3(0, 1, 0))
		momentum = move_vector
		
		# Ground friction
		if slide_time > 0:
			var floor_mom = Vector3(momentum.x, 0, momentum.z)
			momentum -= slide_friction*floor_mom*delta
		elif surf_depth2 <= 0:
			var floor_mom = Vector3(momentum.x, 0, momentum.z)
			momentum -= ground_friction*floor_mom*delta

		# Zero friction
		if (momentum.length() <= MIN_MOM):
			momentum = Vector3(0, momentum.y, 0)
		
		tell_server(delta)
	else:
		runtime -= delta
		# Do tween stuff
		if $RemoteMovement.is_active():
			# end early to start the next one if another one is in queue
			if runtime < SERVER_DELTA*SKIP_FRACTION and len(pos_buffer) > 0:
				# Start next movement
				queue_next_movement(delta)
		else:
			# Start next movement
			queue_next_movement(delta)

func process_animations(delta):
	if surf_depth > 0 or surf_depth2 > 0:
		hitbox_min()
		$Model/Body.surf()
		return
	if abs(momentum.y) > 0.1 and not is_on_floor():
		hitbox_max()
		$Model/Body.jump()
		return
	if slide_time > 0:
		hitbox_min()
		$Model/Body.slide()
		return
	
	if is_crouching or not can_stand():
		hitbox_min()
		if momentum.length() <= MIN_WALK:
			$Model/Body.crouch()
		else:
			$Model/Body.crouchwalk()
		return
	if momentum.length() <= MIN_WALK and is_on_floor():
		hitbox_max()
		$Model/Body.stand()
		return
	
	hitbox_max()
	$Model/Body.walk()

func hitbox_min():
	$CollisionBodyMid.disabled = true
	$CollisionBodyTop.disabled = true

func hitbox_max():
	$CollisionBodyMid.disabled = false
	$CollisionBodyTop.disabled = false

func queue_next_movement(delta):
	$RemoteMovement.stop_all()
	$RemoteMovement.remove_all()
	var ttl = clamp(time_buffer[0] - last_time, SERVER_DELTA/2, 3*SERVER_DELTA)
	runtime = ttl
	if last_time < 0:
		ttl = SERVER_DELTA/2
	$RemoteMovement.interpolate_property(
		self, "translation", translation,
		pos_buffer[0], ttl
	)
	$RemoteMovement.interpolate_property(
		self, "rotation_degrees", rotation_degrees,
		rot_buffer[0], ttl
	)
	$RemoteMovement.start()
	last_time = time_buffer[0]
	momentum = mom_buffer[0]
	
	# update rotation
	var camera_rot = vrot_buffer[0]
	$CameraHinge.rotation_degrees.z = camera_rot
	update_bones()
	
	is_crouching = crouch_buffer[0]
	slide_time = slide_time_buffer[0]
	
	time_buffer.pop_front()
	pos_buffer.pop_front()
	mom_buffer.pop_front()
	rot_buffer.pop_front()
	vrot_buffer.pop_front()
	crouch_buffer.pop_front()
	slide_time_buffer.pop_front()

const MAX_BUFF_LEN = 10
var last_time = OS.get_unix_time()
var time_buffer = []
var pos_buffer = []
var mom_buffer = []
var rot_buffer = []
var vrot_buffer = []
var crouch_buffer = []
var slide_time_buffer = []
func set_remote_values(d, time):
	if len(time_buffer) >= MAX_BUFF_LEN:
		time_buffer.pop_front()
		pos_buffer.pop_front()
		mom_buffer.pop_front()
		rot_buffer.pop_front()
		vrot_buffer.pop_front()
		crouch_buffer.pop_front()
		slide_time_buffer.pop_front()
	time_buffer.append(time)
	var curr = d["position"]
	pos_buffer.append(Vector3(curr[0], curr[1], curr[2]))
	curr = d["momentum"]
	mom_buffer.append(Vector3(curr[0], curr[1], curr[2]))
	curr = d["rotation"]
	rot_buffer.append(Vector3(curr[0], curr[1], curr[2]))
	vrot_buffer.append(d["vrot"])
	crouch_buffer.append(d["is_crouching"])
	slide_time_buffer.append(d["slide_time"])

func update_player(result, response_code, headers, body):
	got_response = true

var SERVER_DELTA = 0.017
#var SERVER_DELTA = 0.008
var SKIP_FRACTION = 1/2
var time_since_last = -1
var got_response = true
func tell_server(delta):
	if Game.singleplayer:
		return
	time_since_last += delta
	
	if time_since_last >= SERVER_DELTA and name == Game.username:
		got_response = false
		time_since_last = 0
		var pos = get_global_transform().origin
		Game.Web.request("update_player", {
			"username": Game.username,
			"players": {
				Game.username : {
					"position": [pos.x, pos.y, pos.z],
					"momentum": [momentum.x, momentum.y, momentum.z],
					"rotation": [0, rotation_degrees.y, 0],
					"vrot": $CameraHinge.rotation_degrees.z,
					"is_crouching": is_crouching,
					"slide_time": slide_time,
				}
			}, 
			"timestamp": OS.get_ticks_msec()
		})

func respawn():
	var spawn_pos = Game.get_node("Map/Arena/ARENA/Spawn").get_global_transform().origin
	var trans = get_global_transform()
	trans.origin = spawn_pos
	set_global_transform(trans)
	momentum = Vector3()

var o_bone_pose = null
var ij = 0
func reset_head():
	var skel = $Model/Body.get_children()[0].get_node("Armature/Skeleton")
	var bone_index = skel.find_bone("head")
	o_bone_pose = skel.get_bone_pose(bone_index)
	update_bones()

func update_bones():
	# Move head and arms
	var camera_rot = $CameraHinge.rotation_degrees
	if o_bone_pose != null:
		#print("changing ", ij)
		ij += 1
		var skel = $Model/Body.get_children()[0].get_node("Armature/Skeleton")
		var bone_index = skel.find_bone("head")
		#var bone_pose = o_bone_pose.rotated(Vector3(1, 0, 0), -camera_rot.z/120)
		var bone_pose = o_bone_pose.rotated(Vector3(1, 0, 0), -camera_rot.z/120)
		skel.set_bone_custom_pose(bone_index, bone_pose)

func set_model(new_model):
	var changed = $Model/Body.set_model(new_model)
	if changed:
		reset_head()

var height = 1
func set_height(n):
	height = n

func make_camera_current():
	var m = $Model/Body.get_children()[0].get_node("Armature/Skeleton/AttachCam/PlayerCamera")
	m.current = true


var head_depth = 0
func _on_StandRoom_body_entered(body):
	print("Something entered " + body.name)
	head_depth += 1


func _on_StandRoom_body_exited(body):
	print("Something exited " + body.name)
	head_depth -= 1

func can_stand():
	return head_depth <= 0
