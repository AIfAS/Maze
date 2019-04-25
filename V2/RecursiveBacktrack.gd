extends Node2D

const N = 1
const E = 2
const S = 4
const W = 8



# dictionary, used as a mapping between 4 directional values and what direction they represent
var cell_walls = {Vector2(0, -1): N, Vector2(1, 0): E, 
				  Vector2(0, 1): S, Vector2(-1, 0): W}
				
var tile_size = 8  # tile size in pixels
var width = 128  # width of map in tiles
var height = 75  # height of map in tiles

# a reference to each map for convenience
onready var Map = $TileMap
onready var Back = $SearchMap
onready var Dot = $DotMap

func _ready():
	OS.set_window_title("Recursive Backtrack Maze")
	randomize()
	tile_size = Map.cell_size
	make_maze()
	for x in range(width):
		for y in range(height):
			Back.set_cellv(Vector2(x, y), 1)
	Back.set_cellv(Vector2(0, 0), 0)
	Back.set_cellv(Vector2(width-1,height-1), 2)
	dot_location(Vector2(0, 0))
	
		
func dot_location(cell):
	Dot.clear()
	Dot.set_cellv(cell, 0)
	
#func 
	
func check_neighbors(cell, unvisited):
	# returns an array of cell's unvisited neighbors
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list
	
func make_maze():
	var unvisited = []  # array of unvisited tiles
	var stack = []
	# fill the map with solid tiles
	Map.clear()
	for x in range(width):
		for y in range(height):
			unvisited.append(Vector2(x, y))
			Map.set_cellv(Vector2(x, y), N|E|S|W) # sets each cell's value to (N+E+S+W)=15, the tilemap index for the tile of index 15, which means all 4 walls (hence the N and E and S and W wall)
			# in documentation, talk about ^, bitwise operation OR symbol, being used here
	var current = Vector2(0, 0)
	unvisited.erase(current)
	# execute recursive backtracker algorithm
	while unvisited: # while the unvisited array is not empty; i.e. there are more cells to visit
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0: # if the current cell has an unvisited neighbour
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			# remove walls from both cells
			var dir = next - current # a direction vector for the direction we just moved in
			var current_walls = Map.get_cellv(current) - cell_walls[dir] # removes the wall from the direction we just came from
			var next_walls = Map.get_cellv(next) - cell_walls[-dir] # removes the opposite wall from the cell above
			Map.set_cellv(current, current_walls) #
			Map.set_cellv(next, next_walls) # set the map cells to the values just calculated
			current = next
			unvisited.erase(current)
		elif stack: # control goes here if the current cell has no neighbours
			current = stack.pop_back() # so we pop the next cell off the the stack and check that one. this is the backtracking part of the algorithm
		yield(get_tree(), 'idle_frame') # puts one frame of delay between each cell calculation, for improved viewing
