extends KinematicBody


var momentum = Vector3()
var gravity = Vector3(0, -30, 0)
var movement_momentum = 80
var ground_friction = 5

const CAM_SENSITIVITY = .3

const MAX_SPEED = 100
const MIN_MOM = 0.4
const MIN_WALK = 0.5

# Jumping
const MAX_JUMP_TIME = 1
const JUMP_MOM = 25
const INIT_JUMP_MOM = 10
var jump_time = 0

var Game = null

# Called when the node enters the scene tree for the first time.
func _ready():
	Game = get_tree().get_current_scene()
	#Game.Web.requests.connect("request_completed", self, "update_player")
	#Game.Web.connect("new_data", self, "update_player")

var runtime = 0

func _process(delta):
	# Movement
	if name == Game.username:
		process_movement(delta)
	
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
		if is_on_floor() or true:
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
	
	process_animations(delta)

func _input(event):
	if name != Game.username:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$CameraHinge.rotate_z(-deg2rad(event.relative.y * CAM_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * CAM_SENSITIVITY * -1))

		var camera_rot = $CameraHinge.rotation_degrees
		camera_rot.z = clamp(camera_rot.z, -50, 50)
		$CameraHinge.rotation_degrees = camera_rot

func process_movement(delta):
	if Input.is_action_pressed("gm_left"):
		momentum += movement_momentum * delta * get_transform().basis.xform(Vector3(0, 0, -1))
	if Input.is_action_pressed("gm_right"):
		momentum += movement_momentum * delta * get_transform().basis.xform(Vector3(0, 0, 1))
	if Input.is_action_pressed("gm_up"):
		momentum += movement_momentum * delta * get_transform().basis.xform(Vector3(1, 0, 0))
	if Input.is_action_pressed("gm_down"):
		momentum += movement_momentum * delta * get_transform().basis.xform(Vector3(-1, 0, 0))
	if Input.is_action_pressed("gm_jump"):
		#if $FNormCast.is_colliding():
		if is_on_floor():
			jump_time = MAX_JUMP_TIME
			#momentum += INIT_JUMP_MOM * get_transform().basis.xform(Vector3(0, 1, 0))
			momentum.y = INIT_JUMP_MOM
		elif not is_on_ceiling() and jump_time > 0:
			jump_time -= delta
			momentum += JUMP_MOM * (jump_time/MAX_JUMP_TIME) * delta * get_transform().basis.xform(Vector3(0, 1, 0))
	else:
		jump_time = 0

func process_animations(delta):
	if Input.is_action_pressed("gm_int1") and name == Game.username:
		$Model/Body.shoot()
	elif momentum.length() <= MIN_WALK and is_on_floor():
		$Model/Body.stand()
	else:
		$Model/Body.walk()

func queue_next_movement(delta):
	$RemoteMovement.stop_all()
	$RemoteMovement.remove_all()
	var ttl = clamp(pos_buffer_time[0] - last_time, SERVER_DELTA/2, 3*SERVER_DELTA)
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
	last_time = pos_buffer_time[0]
	momentum = mom_buffer[0]
	pos_buffer.pop_front()
	pos_buffer_time.pop_front()
	mom_buffer.pop_front()
	mom_buffer_time.pop_front()
	rot_buffer.pop_front()
	rot_buffer_time.pop_front()

const POS_BUFFER_LEN = 10
var pos_buffer = []
var pos_buffer_time = []
var last_time = OS.get_unix_time()
func set_pos(v, time):
	pos_buffer.append(v)
	pos_buffer_time.append(time)
	if len(mom_buffer) > POS_BUFFER_LEN:
		pos_buffer.pop_front()
		pos_buffer_time.pop_front()

const MOM_BUFFER_LEN = 10
var mom_buffer = []
var mom_buffer_time = []
func set_mom(m, time):
	mom_buffer.append(m)
	mom_buffer_time.append(time)
	if len(mom_buffer) > MOM_BUFFER_LEN:
		mom_buffer.pop_front()
		mom_buffer_time.pop_front()

const ROT_BUFFER_LEN = 10
var rot_buffer = []
var rot_buffer_time = []
func set_rot(m, time):
	rot_buffer.append(m)
	rot_buffer_time.append(time)
	if len(rot_buffer) > ROT_BUFFER_LEN:
		rot_buffer.pop_front()
		rot_buffer_time.pop_front()

func update_player(result, response_code, headers, body):
	got_response = true

var SERVER_DELTA = 0.017
#var SERVER_DELTA = 0.008
var SKIP_FRACTION = 0
var time_since_last = -1
var got_response = true
func tell_server(delta):
	if Game.singleplayer:
		return
	time_since_last += delta
	#if time_since_last >= SERVER_DELTA and got_response and name == Game.username:
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
					"rotation": [0, rotation_degrees.y, 0]
				}
			}, 
			"timestamp": OS.get_unix_time()
		})

func respawn():
	var spawn_pos = Game.get_node("Map/Arena/ARENA/Spawn").get_global_transform().origin
	var trans = get_global_transform()
	trans.origin = spawn_pos
	set_global_transform(trans)
