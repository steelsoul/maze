extends Node2D

export (PackedScene) var Cell

var maze = [5, 4, 
1, 1, 1, 1, 1, 0, 1, 1, 1, 0,
0, 1, 1, 0, 0, 1, 0, 0, 1, 1,
0, 1, 1, 0, 1, 0, 0, 0, 0, 0,
1, 1, 0, 0, 0, 1, 0, 1, 0, 1]

func read_file(file_name):
	var file = File.new()
	file.open("user://" + file_name, File.READ)
	var w = file.get_8()
	var h = file.get_8()
	var repo = make_array_of_cells(w,h)
	var x = 0
	var y = 0
	while (x+1)*(y+1) != 2*w*h:
		var up = file.get_8()
		var left = file.get_8()
		if x == 2*w:
			y = y + 1
			x = 0
		x = x + 1
		var cell = configure_cell(repo,x,y,up,left)
		add_child(cell)
	return repo

func write_file(file_name, repo):
	var file = File.new()
	file.open("user://" + file_name, File.WRITE)
	var w = repo.size()
	var h = repo[0].size()
	file.store_8(w)
	file.store_8(h)
	var x = 0
	var y = 0
	while (x + 1)*(y + 1) != w*h:
		var cell = repo[x][y]
		file.store_8(cell.is_top())
		file.store_8(cell.is_left())
		x = x + 1
		if x == w:
			x = 0
			y = y + 1

func create_rep(maze):
	var w = maze[0]
	var h = maze[1]
	var repo = make_array_of_cells(w,h)
	for y in range(0, h):
		for x in range(0, w):
			var up = false
			var left = false
			if maze[2*x+2*y*w+2] == 1: up = true
			if maze[2*x+2*y*w+3] == 1: left = true
			var cell = configure_cell(repo,x,y,up,left)
			add_child(cell)
			print(x, " - ", y, "u", up, " l", left)
	for x in range(0, w):
		add_child(create_cell(x,h,true,false))
	for y in range(0, h):
		add_child(create_cell(w,y,false,true))
	add_child(create_corner_cell(w,h))
	return repo

func create_cell(x,y,up,left):
	var cell = Cell.instance()
	var cell_size = cell.get_size()
	cell.position = Vector2(x*cell_size, y*cell_size)
	cell.setup(up, left)
	return cell

func configure_cell(repo,x,y,up,left):
	var cell = get_cell(x,y,repo)
	var cell_size = cell.get_size()
	cell.position = Vector2(x*cell_size, y*cell_size)
	cell.setup(up, left)
	return cell

func create_corner_cell(x,y):
	var cell = Cell.instance()
	var cell_size = cell.get_size()
	cell.position = Vector2(x*cell_size, y*cell_size)
	cell.make_corner()
	return cell

func make_array_of_cells(w,h):
	var result_maze = []
	for x in range(w):
		result_maze.append([])
		var y = 0
		while y < h:
			result_maze[x].append(Cell.instance())
			y = y + 1
	return result_maze

func get_cell(x,y,repo):
	return repo[x][y]

func new_game():
	pass

func _ready():
	randomize()
	var repo = create_rep(maze)