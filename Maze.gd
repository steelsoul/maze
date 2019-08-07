extends Node2D

export (PackedScene) var Cell
var maze = [5, 4, 
	1, 1, 1, 1, 1, 0, 1, 1, 1, 0,
	0, 1, 1, 0, 0, 1, 0, 0, 1, 1,
	0, 1, 1, 0, 1, 0, 0, 0, 0, 0,
	1, 1, 0, 0, 0, 1, 0, 1, 0, 1]

func create_rep():
	var w = maze[0]
	var h = maze[1]
	for y in range(0, h):
		for x in range(0, w):
			var up = false
			var left = false
			if maze[2*x+2*y*w+2] == 1: up = true
			if maze[2*x+2*y*w+3] == 1: left = true
			add_child(create_cell(x,y,up,left))
			print(x, " - ", y, "u", up, " l", left)
	for x in range(0, w):
		add_child(create_cell(x,h,true,false))
	for y in range(0, h):
		add_child(create_cell(w,y,false,true))

func create_cell(x,y,up,left):
	var cell = Cell.instance()
	var cell_size = cell.get_size()
	cell.position = Vector2(x*cell_size, y*cell_size)
	cell.setup(up, left)
	return cell

func new_game():
	pass

func _ready():
	randomize()
	create_rep()
	pass
