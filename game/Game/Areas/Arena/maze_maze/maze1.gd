extends Spatial

const LENGTH = 50
const HEIGHT = 50

const NUMBER_ROOMS = 30
const MAX_ROOM_SIZE = 6
const MIN_ROOM_SIZE = 3

const MAX_DOORS = 2

var dungeon = []

var mazefloor = preload("res://Game/Areas/Arena/maze_maze/mazefloor.tscn")
var mazewall = preload("res://Game/Areas/Arena/maze_maze/mazewall.tscn")

onready var Game = get_tree().get_current_scene()

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
						testDungeon[yy + i][xx + j] = 1
					else: 
						testDungeon[yy + i][xx + j] = 2
						
					j += 1
				else:
					valid = false
					
			i += 1

		#print("room attempt")
		#printt("x", xx, "y", yy, "l", l, "h", h)
		if valid:
			#print('valid room')
			dungeon = testDungeon
			rooms.append({"x": xx, "y": yy, "l": l, "h": h})
		else:
			invalid_rooms += 1
	
	print(invalid_rooms)
	
	# create doors
	for room in rooms:
		for iter in range(MAX_DOORS):
			var side = rng.randi() % 4

			# top
			if side == 0:
				var j = room["x"] + randi() % (room["l"] - 2) + 1
				
				var ii = room["y"] - 1
				var found_room = false
				
				while ii >= 0:
					if dungeon[ii][j] == 2 or dungeon[ii][j] == 3:
						found_room = true
						break
						
					ii -= 1
					
				if found_room:
					for i in range(ii + 1, room["y"] + 1):
						dungeon[i][j] = 3
			
			# right
			if side == 1:
				var i = room["y"] + randi() % (room["h"] - 2) + 1
				
				var jj = room["x"] + room["l"]
				var found_room = false
				
				while jj < LENGTH:
					if dungeon[i][jj] == 2 or dungeon[i][jj] == 3:
						found_room = true
						break
						
					jj += 1
					
				if found_room:
					for j in range(room["x"] + room["l"] - 1, jj):
						dungeon[i][j] = 3
						
			# bottom
			if side == 2:
				var j = room["x"] + randi() % (room["l"] - 2) + 1
				
				var ii = room["y"] + room["h"]
				var found_room = false
				
				while ii < HEIGHT:
					if dungeon[ii][j] == 2 or dungeon[ii][j] == 3:
						found_room = true
						break
						
					ii += 1
					
				if found_room:
					for i in range(room["y"] + room["h"] - 1, ii):
						dungeon[i][j] = 3
			
			# left
			if side == 3:
				var i = room["y"] + randi() % (room["h"] - 2) + 1
				
				var jj = room["x"] - 1
				var found_room = false
				
				while jj >= 0:
					if dungeon[i][jj] == 2 or dungeon[i][jj] == 3:
						found_room = true
						break
						
					jj -= 1
					
				if found_room:
					for j in range(jj + 1, room["x"] + 1):
						dungeon[i][j] = 3
						
	# add rooms
	for i in range(HEIGHT):
		for j in range(LENGTH):
			var obj
			if dungeon[i][j] <= 1:
				obj = mazewall.instance()
				obj.translate(Vector3(4.0*j, 0, 4.0*i))
				self.add_child(obj)
			else:
				obj = mazefloor.instance()
				obj.translate(Vector3(4.0*j, 0, 4.0*i))
				self.add_child(obj)
				
	# set spawn point
	var ii = 0
	var jj = 0
	while dungeon[ii][jj] <= 1:
		ii = rng.randi() % HEIGHT
		jj = rng.randi() % LENGTH
	
	$"Spawn/1".translate(Vector3(4.0*jj, 0, 4.0*ii))
