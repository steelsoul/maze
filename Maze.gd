extends Node2D

export (PackedScene) var Cell
export (PackedScene) var Ball

enum Dir {Left, Right, Down, Up}
var buffer = PoolStringArray()

func solve_maze_with_wave_tracing(repo, xs, ys, xf, yf):
	var w = repo[0]
	var h = repo[1]
	var rep = repo[2]
	var marks_array = create_marks_array(w,h)
	var n_iter = 1
	marks_array[xs][ys] = 1
	var finished = false
	while !finished:
		var x = 0
		var no_further_steps = true
		while x < w:
			var y = 0
			while y < h:
				if n_iter == 4: 
					print("!")
				if marks_array[x][y] == n_iter:
					for dir in Dir.values():
						if can_go(repo, x, y, dir, marks_array, 0):
							print("can go ", describe(dir),  " from (", x, ",", y, ") on iter ", n_iter)
							no_further_steps = false
							mark_neighbour(marks_array, x, y, dir, n_iter + 1)
							if check_finish(x, y, xf, yf, dir) == true:
								return [true, marks_array]
							pass
				y = y + 1
			x = x + 1
		n_iter = n_iter + 1
		if no_further_steps: 
			finished = true
	return [false]

func describe(dir):
	match dir:
		Dir.Left:
			return "Left"
		Dir.Right:
			return "Right"
		Dir.Up:
			return "Up"
		Dir.Down:
			return "Down"

func can_go(repo, x, y, dir, marks_array, n_iter):
	var w = repo[0]
	var h = repo[1]
	var rep = repo[2]
	match dir:
		Dir.Left:
			return x > 0 && !rep[x][y].is_left() && marks_array[x-1][y] == n_iter
		Dir.Right:
			return x < w-1 && !rep[x+1][y].is_left() && marks_array[x+1][y] == n_iter
		Dir.Up:
			return y > 0 && !rep[x][y].is_top() && marks_array[x][y-1] == n_iter
		Dir.Down:
			return y < h-1 && !rep[x][y+1].is_top() && marks_array[x][y+1] == n_iter

func create_marks_array(w,h):
	var result_array = []
	for x in range(w):
		result_array.append([])
		var y = 0
		while y < h:
			result_array[x].append(0)
			y = y + 1
	return result_array

func mark_neighbour(rep, x, y, dir, n_iter):
	match dir:
		Dir.Left: 
			rep[x-1][y] = n_iter
		Dir.Right: 
			rep[x+1][y] = n_iter
		Dir.Up: 
			rep[x][y-1] = n_iter
		Dir.Down:
			rep[x][y+1] = n_iter

func check_finish(x, y, xf, yf, dir):
	var xn = x
	var yn = y
	if dir == Dir.Left: xn = x - 1
	elif dir == Dir.Right: xn = x + 1
	elif dir == Dir.Up: yn = y - 1
	else: yn = y + 1
	return xf == xn and yf == yn

func read_file(file_name):
	var file = File.new()
	file.open("res://" + file_name, File.READ)
	print("e: ", file.get_error(), ", available: ", file.is_open())
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
#		print("ac: ", x, ' ', y)
		x = x + 1
		add_child(cell)
	finalize_rep(w,h)
	return [w, h, repo]

func write_file(file_name, repo):
	var file = File.new()
	file.open("res://" + file_name, File.WRITE)
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

func read_next_byte_from_csv(file):
	if buffer.size() == 0 || buffer.size() == 1:
		buffer = file.get_csv_line()
	var result = buffer[0] as int
	buffer.remove(0)
	return result

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

func show_solution(repo, marks_array, xf, yf):
	var n_iter = marks_array[xf][yf]
	var x = xf
	var y = yf
	var cell_size = Cell.instance().get_size()
	var cell_size_2 = cell_size / 2
	while (n_iter >= 0):
		var ball = Ball.instance()
		ball.position = Vector2(x * cell_size + cell_size_2, y * cell_size + cell_size_2)
		add_child(ball)
		for dir in Dir.values():
			if can_go(repo, x, y, dir, marks_array, n_iter - 1):
				match dir:
					Dir.Up:
						y = y - 1
					Dir.Left:
						x = x - 1
					Dir.Down:
						y = y + 1
					Dir.Right:
						x = x + 1
				break
		n_iter = n_iter - 1
	
func _ready():
	randomize()
	var repo_info = read_file("maze1.txt")
	var xs = 0
	var ys = 0
	var xf = 4
	var yf = 0
	var solution_info = solve_maze_with_wave_tracing(repo_info, xs, ys, xf, yf)
	print("can solve: ", solution_info[0])
	if solution_info[0]:
		show_solution(repo_info, solution_info[1], xf, yf)