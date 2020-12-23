extends Spatial

const LENGTH = 60
const HEIGHT = 60

const NUMBER_ROOMS = 30
const MAX_ROOM_SIZE = 10
const MIN_ROOM_SIZE = 4

const MAX_DOORS = 3

var ROOM_SCALE = 4.0

var dungeon = []
enum EnvironmentType {WALL, ROOM_OUTER, ROOM_INNER, HALLWAY}
var dungeon_spawns = []
enum SpawnType {PLAYER, GUN, ENEMY}

var mazefloor = preload("res://Game/Arena/Arenas/Maze1/maze_maze/mazefloor.tscn")
var mazewall = preload("res://Game/Arena/Arenas/Maze1/maze_maze/mazewall.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.set_seed(Game.settings["random_seed"] )
	
	# generate dungeon here
	# 0 or NULL for walls
	# 1 for room outer
	# 2 for room inner
	# 3 for hallways
	
	for x in range(LENGTH):
		dungeon.append([])
		for y in range(HEIGHT):
			dungeon[x].append(0)
	
	var rooms = []
	var invalid_rooms = 0
	while len(rooms) < NUMBER_ROOMS:
		var l = (rng.randi() % (MAX_ROOM_SIZE - 2 - MIN_ROOM_SIZE)) + 2 + MIN_ROOM_SIZE
		var h = (rng.randi() % (MAX_ROOM_SIZE - 2 - MIN_ROOM_SIZE)) + 2 + MIN_ROOM_SIZE

		var xx = rng.randi() % (LENGTH - l)
		var yy = rng.randi() % (HEIGHT - h)
		
		var testDungeon = dungeon.duplicate(true)
		var valid = true
		
		var i = 0
		while i < h and valid:
			var j = 0
			while j < l and valid:
				if testDungeon[yy + i][xx + j] == 0:
					if i == 0 or i == h - 1 or j == 0 or j == l - 1:
						testDungeon[yy + i][xx + j] = EnvironmentType.WALL
					else: 
						testDungeon[yy + i][xx + j] = EnvironmentType.ROOM_INNER
						
					j += 1
				else:
					valid = false
					
			i += 1

		if valid:
			dungeon = testDungeon
			rooms.append({"x": xx, "y": yy, "l": l, "h": h})
		else:
			invalid_rooms += 1
	
	for i in len(rooms):
		dungeon_spawns.append(SpawnType.ENEMY)
	dungeon_spawns[rng.randi() % len(dungeon_spawns)] = SpawnType.PLAYER
	
	# create doors & enemy spawns
	for z in len(rooms):
		var room = rooms[z]
		# Create Spawns
		# TODO: make 1 room a player spawner, 1 room end
		# TODO: gauruntee that the maze is solvable
		if dungeon_spawns[z] == SpawnType.ENEMY:
			var new_spawner = Resources.make_obj("EnemySpawner")
			if new_spawner:
				new_spawner.set_width_height(room["l"]*2 - 3, room["h"]*2 - 3)
				var trans = new_spawner.get_global_transform()
				var centerx = room["x"] + float(room["l"])/2.0 - .5
				var centery = room["y"] + float(room["h"])/2.0 - .5
				trans.origin = Vector3(
					ROOM_SCALE * centerx, 0, ROOM_SCALE * centery
				)
				new_spawner.set_global_transform(trans)
	#			new_spawner.translate(Vector3(4.0*room["x"], 0, 4.0*room["y"]))
			else:
				push_warning("Could not make EnemySpawner")
		if dungeon_spawns[z] == SpawnType.PLAYER:
			var new_spawner = Resources.make_obj("MazePlayerSpawner")
			if new_spawner:
				var trans = new_spawner.get_global_transform()
				var centerx = room["x"] + float(room["l"])/2.0 - .5
				var centery = room["y"] + float(room["h"])/2.0 - .5
				trans.origin = Vector3(
					ROOM_SCALE * centerx, 0, ROOM_SCALE * centery
				)
				new_spawner.set_global_transform(trans)
				new_spawner.set_width_height(room["l"]*2 - 3, room["h"]*2 - 3)
	#			new_spawner.translate(Vector3(4.0*room["x"], 0, 4.0*room["y"]))
			else:
				push_warning("Could not make MazePlayerSpawner")
		
		# Create doors
		for iter in range(MAX_DOORS):
			var side = rng.randi() % 4

			# top
			if side == 0:
				var j = room["x"] + rng.randi() % (room["l"] - 2) + 1
				
				var ii = room["y"] - 1
				var found_room = false
				
				while ii >= 0:
					if dungeon[ii][j] == EnvironmentType.ROOM_INNER or dungeon[ii][j] == EnvironmentType.HALLWAY:
						found_room = true
						break
						
					ii -= 1
					
				if found_room:
					for i in range(ii + 1, room["y"] + 1):
						dungeon[i][j] = EnvironmentType.HALLWAY
			
			# right
			if side == 1:
				var i = room["y"] + rng.randi() % (room["h"] - 2) + 1
				
				var jj = room["x"] + room["l"]
				var found_room = false
				
				while jj < LENGTH:
					if dungeon[i][jj] == EnvironmentType.ROOM_INNER or dungeon[i][jj] == EnvironmentType.HALLWAY:
						found_room = true
						break
						
					jj += 1
					
				if found_room:
					for j in range(room["x"] + room["l"] - 1, jj):
						dungeon[i][j] = EnvironmentType.HALLWAY
						
			# bottom
			if side == 2:
				var j = room["x"] + rng.randi() % (room["l"] - 2) + 1
				
				var ii = room["y"] + room["h"]
				var found_room = false
				
				while ii < HEIGHT:
					if dungeon[ii][j] == EnvironmentType.ROOM_INNER or dungeon[ii][j] == EnvironmentType.HALLWAY:
						found_room = true
						break
						
					ii += 1
					
				if found_room:
					for i in range(room["y"] + room["h"] - 1, ii):
						dungeon[i][j] = EnvironmentType.HALLWAY
			
			# left
			if side == 3:
				var i = room["y"] + rng.randi() % (room["h"] - 2) + 1
				
				var jj = room["x"] - 1
				var found_room = false
				
				while jj >= 0:
					if dungeon[i][jj] == EnvironmentType.ROOM_INNER or dungeon[i][jj] == EnvironmentType.HALLWAY:
						found_room = true
						break
						
					jj -= 1
					
				if found_room:
					for j in range(jj + 1, room["x"] + 1):
						dungeon[i][j] = EnvironmentType.HALLWAY
						
	# add rooms
	for i in range(HEIGHT):
		for j in range(LENGTH):
			var obj
			if dungeon[i][j] in [EnvironmentType.WALL, EnvironmentType.ROOM_OUTER]:
				obj = mazewall.instance()
				obj.translate(Vector3(ROOM_SCALE*j, 0, ROOM_SCALE*i))
				self.add_child(obj)
			else:
				obj = mazefloor.instance()
				obj.translate(Vector3(ROOM_SCALE*j, 0, ROOM_SCALE*i))
				self.add_child(obj)
				
	# set spawn point
	var ii = 0
	var jj = 0
	while dungeon[ii][jj] <= 1:
		ii = rng.randi() % HEIGHT
		jj = rng.randi() % LENGTH
	
	# FYI this below only works because Spawn is set to Vector3.ZERO
	#$"Spawn/1".translate(Vector3(ROOM_SCALE*jj, 0, ROOM_SCALE*ii))
