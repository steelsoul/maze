extends Node2D

export (PackedScene) var Cell

var maze = [5, 4, 
1, 1, 1, 1, 1, 0, 1, 1, 1, 0,
0, 1, 1, 0, 0, 1, 0, 0, 1, 1,
0, 1, 1, 0, 1, 0, 0, 0, 0, 0,
1, 1, 0, 0, 0, 1, 0, 1, 0, 1]

var buffer = PoolStringArray()

func read_next_byte_from_csv(file):
	if buffer.size() == 0 || buffer.size() == 1:
		buffer = file.get_csv_line()
	var result = buffer[0] as int
	buffer.remove(0)
	return result

func read_file(file_name):
	var file = File.new()
	file.open("res://" + file_name, File.READ)
	print("e: ", file.get_error(), ", available: ", file.is_open())
	var buffer = PoolStringArray()
	var w = read_next_byte_from_csv(file)
	var h = read_next_byte_from_csv(file)
	print("w: ", w, ", h: ", h)
	var repo = make_array_of_cells(w,h)
	var x = 0
	var y = 0
	while (x+1)*(y+1) != w*h:
		var up = read_next_byte_from_csv(file)
		var left = read_next_byte_from_csv(file)
		if x == w:
			y = y + 1
			x = 0
		var cell = configure_cell(repo,x,y,up,left)
		print("ac: ", x, ' ', y)
		x = x + 1
		add_child(cell)
	finalize_rep(w,h)
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
#			print(x, " - ", y, "u", up, " l", left)
	finalize_rep(w,h)
	return repo

func finalize_rep(w,h):
	for x in range(0, w):
		add_child(create_cell(x,h,true,false))
	for y in range(0, h):
		add_child(create_cell(w,y,false,true))
	add_child(create_corner_cell(w,h))

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
	var repo = read_file("maze1.txt")
#	var repo = create_rep(maze)