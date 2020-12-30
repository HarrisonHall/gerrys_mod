extends Spatial

const LENGTH = 60
const WIDTH = 60

# DO NOT CHANGE THIS WITHOUT CHANGING WALL SIZES OR SOMETHING
const GRID_SIZE = 4

const MAX_FLOOR_HEIGHT = 18
const HEIGHT = 24

const NUMBER_ROOMS = 40
const COST = 8.0
const MAX_DOORS = 3

# KEEP THESE NUMBERS ODD PLEASE
const MAX_ROOM_SIZE = 11
const MIN_ROOM_SIZE = 3

var mazeceiling = preload("res://Game/Arena/Arenas/Maze2/maze2_maze2/mazeceling2.tscn")
var mazefloor = preload("res://Game/Arena/Arenas/Maze2/maze2_maze2/mazefloor2.tscn")
var mazewall = preload("res://Game/Arena/Arenas/Maze2/maze2_maze2/mazewall2.tscn")
var stairs = preload("res://Game/Arena/Arenas/Maze2/maze2_maze2/mazestairs2.tscn")
var jumppad = preload("res://Game/Objects/BoostPad/BoostPad.tscn")

var dungeon = []
var dungeon_rooms = []
var astar = AStar2D.new()

func _ready():
	# 0 = wall
	var rng = RandomNumberGenerator.new()
	rng.set_seed(Game.settings["random_seed"])
	var ra = rng.randi() % 10000
	var spb = StreamPeerBuffer.new()
	spb.data_array = (str(ra) + get_name() + str(ra)).sha1_buffer()
	rng.set_seed(spb.get_64())
		
	for i in range(WIDTH):
		dungeon.append([])
		for j in range(LENGTH):
			dungeon[i].append(Vector2(-1, -1))

	# add room positions
	while len(dungeon_rooms) < NUMBER_ROOMS:
		var dx = rng.randi_range(MIN_ROOM_SIZE / 2 + 1, LENGTH - MIN_ROOM_SIZE / 2 - 1)
		var dz = rng.randi_range(MIN_ROOM_SIZE / 2 + 1, WIDTH - MIN_ROOM_SIZE / 2 - 1)
		
		var valid = true
		for room in dungeon_rooms:
			# change this to <= MIN_ROOM_SIZE if we don't want the rooms to be touching
			if abs(dx - room["x"]) < MIN_ROOM_SIZE and abs(dz - room["z"]) < MIN_ROOM_SIZE:
				valid = false
				
		if valid:
			var room = {}
			room["x"] = dx
			room["z"] = dz
			room["id"] = len(dungeon_rooms)
			room["num"] = room["id"]
			
			var maxlength = min(min(MAX_ROOM_SIZE, dx), abs(LENGTH - dx))
			var maxwidth = min(min(MAX_ROOM_SIZE, dz), abs(WIDTH - dz))
			room["length"] = rng.randi_range(MIN_ROOM_SIZE, maxlength) / 2 * 2 + 1
			room["width"] = rng.randi_range(MIN_ROOM_SIZE, maxwidth) / 2 * 2 + 1
			
			for i in range(dx - room["length"] / 2, dx + room["length"] / 2 + 1):
				for j in range(dz - room["width"] / 2, dz + room["width"] / 2 + 1):
					dungeon[j][i] = Vector2(0, HEIGHT)
			
			dungeon_rooms.append(room)

	# merge rooms together
	var flag = true
	
	while flag:
		flag = false
		for room1 in dungeon_rooms:
			for room2 in dungeon_rooms:
				if room1["num"] != room2["num"]:
					# rooms overlapping
					var xdist = abs(room1["x"] - room2["x"])
					var zdist = abs(room1["z"] - room2["z"])
					var xlen = (room1["length"] + room2["length"]) / 2
					var zlen = (room1["width"] + room2["width"]) / 2
					
					if (xdist < xlen and zdist <= zlen) or (xdist <= xlen and zdist < zlen):
						if rng.randi() % 2 == 1:
							room2["num"] = room1["num"]
						else:
							room1["num"] = room2["num"]
							
						flag = true
		
	var dungeon_rooms_dict = {}
	for room in dungeon_rooms:
		var r = dungeon_rooms_dict.get(room["num"], [])
		r.append(room)
		dungeon_rooms_dict[room["num"]] = r
		
	dungeon_rooms = dungeon_rooms_dict
	print(len(dungeon_rooms))
	
	# connect rooms
	var id = 0
	for j in range(WIDTH):
		for i in range(LENGTH):
			var cost = 1
			if dungeon[j][i].x == -1:
				if j > 0:
					if dungeon[j - 1][i].x != -1:
						cost += 0.25 * COST
				if j < WIDTH - 1:
					if dungeon[j + 1][i].x != -1:
						cost += 0.25 * COST
				if i > 0:
					if dungeon[j][i - 1].x != -1:
						cost += 0.25 * COST
				if i < LENGTH - 1:
					if dungeon[j][i + 1].x != -1:
						cost += 0.25 * COST

			astar.add_point(id, Vector2(i, j), cost)
			id += 1

	for j in range(WIDTH):
		for i in range(LENGTH):
			if i < LENGTH - 1:
				astar.connect_points(j * LENGTH + i, j * LENGTH + i + 1)
			if j < WIDTH - 1:
				astar.connect_points(j * LENGTH + i, (j + 1) * LENGTH + i )

	# add hallways and set height
	var room_numbers = []
	var connecting_rooms = []
	for r in dungeon_rooms:
		var floor_height = rng.randi_range(0, MAX_FLOOR_HEIGHT)
		var room_height = HEIGHT
		
		for room in dungeon_rooms[r]:
			room["floor_height"] = floor_height
			room["room_height"] = room_height
			
			for i in range(room["x"] - room["length"] / 2, room["x"] + room["length"] / 2 + 1):
				for j in range(room["z"] - room["width"] / 2, room["z"] + room["width"] / 2 + 1):
					dungeon[j][i].x = floor_height
					dungeon[j][i].y = HEIGHT
		
		connecting_rooms.append(dungeon_rooms[r][0])
		
	var connected_rooms = []
	var room1 = connecting_rooms[0]
	while len(connected_rooms) < len(connecting_rooms) - 1:
		var closestRoom = connecting_rooms[0]
		var closestRoomDist = LENGTH * WIDTH
		
		for room2 in connecting_rooms:
			if room2 == room1 or room2 in connected_rooms:
				continue
				
			var dis = Vector2(room1["x"], room1["z"]).distance_squared_to(Vector2(room2["x"], room2["z"]))
			if dis < closestRoomDist:
				closestRoomDist = dis
				closestRoom = room2
				
		connected_rooms.append(room1)
			
		var path = astar.get_point_path(room1["z"] * LENGTH + room1["x"], closestRoom["z"] * LENGTH + closestRoom["x"])
			
		for p in path:
			if dungeon[p.y][p.x].x == -1:
				dungeon[p.y][p.x] = Vector2(room1["floor_height"], room1["room_height"])
				astar.add_point(p.y * LENGTH + p.x, Vector2(p.x, p.y), COST)

		#printt(room1, closestRoom)
		room1 = closestRoom
		
	# add rooms
	for j in range(LENGTH):
		for i in range(WIDTH):
			if dungeon[i][j].x == -1:
				#pass
				var obj = mazewall.instance()
				obj.translate(Vector3(GRID_SIZE*j, 0, GRID_SIZE*i))
				self.add_child(obj)
			else:
				var obj = mazefloor.instance()
				obj.translate(Vector3(GRID_SIZE*j, dungeon[i][j].x, GRID_SIZE*i))
				self.add_child(obj)
				
				obj = mazeceiling.instance()
				obj.translate(Vector3(GRID_SIZE*j, dungeon[i][j].y, GRID_SIZE*i))
				self.add_child(obj)
				
				obj = mazewall.instance()
				obj.translate(Vector3(GRID_SIZE*j, dungeon[i][j].x - 24 - 0.6, GRID_SIZE*i))
				self.add_child(obj)
				
				if i > 0 and dungeon[i - 1][j].x > dungeon[i][j].x:
					if dungeon[i - 1][j].x - dungeon[i][j].x < 5:
						obj = stairs.instance()
						obj.translate(Vector3(GRID_SIZE*j, dungeon[i][j].x, GRID_SIZE*i))
						obj.scale = Vector3(1, (dungeon[i - 1][j].x - dungeon[i][j].x) / 2, 1)
						obj.rotate_y(-PI/2)
						self.add_child(obj)
					else:
						obj = jumppad.instance()
						obj.translate(Vector3(GRID_SIZE*j, dungeon[i][j].x, GRID_SIZE*i))
						self.add_child(obj)
				elif i < WIDTH - 1 and dungeon[i + 1][j].x > dungeon[i][j].x:
					if dungeon[i + 1][j].x - dungeon[i][j].x < 5:
						obj = stairs.instance()
						obj.translate(Vector3(GRID_SIZE*j, dungeon[i][j].x, GRID_SIZE*i))
						obj.scale = Vector3(1, (dungeon[i + 1][j].x - dungeon[i][j].x) / 2, 1)
						obj.rotate_y(PI/2)
						self.add_child(obj)
					else:
						obj = jumppad.instance()
						obj.translate(Vector3(GRID_SIZE*j, dungeon[i][j].x, GRID_SIZE*i))
						self.add_child(obj)
				elif j > 0 and dungeon[i][j - 1].x > dungeon[i][j].x:
					if dungeon[i][j - 1].x - dungeon[i][j].x < 5:
						obj = stairs.instance()
						obj.translate(Vector3(GRID_SIZE*j, dungeon[i][j].x, GRID_SIZE*i))
						obj.scale = Vector3(1, (dungeon[i][j - 1].x - dungeon[i][j].x) / 2, 1)
						obj.rotate_y(0)
						self.add_child(obj)
					else:
						obj = jumppad.instance()
						obj.translate(Vector3(GRID_SIZE*j, dungeon[i][j].x, GRID_SIZE*i))
						self.add_child(obj)
				elif j < LENGTH - 1 and dungeon[i][j + 1].x > dungeon[i][j].x:
					if dungeon[i][j + 1].x - dungeon[i][j].x < 5:
						obj = stairs.instance()
						obj.translate(Vector3(GRID_SIZE*j, dungeon[i][j].x, GRID_SIZE*i))
						obj.scale = Vector3(1, (dungeon[i][j + 1].x - dungeon[i][j].x) / 2, 1)
						obj.rotate_y(PI)
						self.add_child(obj)
					else:
						obj = jumppad.instance()
						obj.translate(Vector3(GRID_SIZE*j, dungeon[i][j].x, GRID_SIZE*i))
						self.add_child(obj)
				
	# set spawn point
	var ii = 0
	var jj = 0
	var hh = 0
	while dungeon[ii][jj].x == -1:
		ii = rng.randi() % WIDTH
		jj = rng.randi() % LENGTH
		hh = dungeon[ii][jj].x
	
	# FYI this below only worked because Spawn is set to Vector3.ZERO
	$"Spawn/1".translate(Vector3(GRID_SIZE*jj, hh, GRID_SIZE*ii))
