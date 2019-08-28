extends Node2D

export (PackedScene) var Cell
export (PackedScene) var Ball

enum Dir {Left, Right, Down, Up}
var buffer = PoolStringArray()
var g_start = Vector2(0, 0)
var g_finish = Vector2(0,0)
var g_thread
var g_rep

signal on_generation_done

func _ready():
	randomize()
#	var repo_info = read_file("maze1.txt")
	var dim_x = 15
	var dim_y = 10
	g_finish = Vector2(dim_x - 1, dim_y - 1)
#	var repo_info = generate_prima(Vector2(dim_x, dim_y))
	g_thread = Thread.new()
	g_thread.start(self, "generate_kruskal", Vector2(dim_x, dim_y))
#	g_thread.start(self, "generate_prima", Vector2(dim_x, dim_y))
	#var repo_info = generate_kruskal(Vector2(dim_x, dim_y))

func _exit_tree():
	g_thread.wait_to_finish()

func _on_Button_pressed():
	var solution_info = solve_maze_with_wave_tracing(g_rep, g_start.x, g_start.y, g_finish.x, g_finish.y)
	print("can solve: ", solution_info[0])
	if solution_info[0]:
		show_solution(g_rep, solution_info[1], g_finish.x, g_finish.y)

func _on_Goal_reach_goal():
	print("Hey, you have won! Congrats!!!")

func _on_Maze_on_generation_done():
	load_repo(g_rep)
	put_player(g_start.x, g_start.y)
	put_goal(g_finish.x, g_finish.y)

func solve_maze_with_wave_tracing(repo, xs, ys, xf, yf):
	var w = repo[0]
	var h = repo[1]
	var marks_array = create_marks_array(w,h)
	var n_iter = 1
	marks_array[xs][ys] = n_iter
	var finished = false
	while !finished:
		var x = 0
		var no_further_steps = true
		while x < w:
			var y = 0
			while y < h:
				if marks_array[x][y] == n_iter:
					for dir in Dir.values():
						if can_go(repo, x, y, dir, marks_array, 0):
#							print("can go ", describe(dir),  " from (", x, ",", y, ") on iter ", n_iter)
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

func load_repo(repo):
	var width = repo[0]
	var height = repo[1]
	var cells = repo[2]
	for x in width:
		for y in height:
			add_child(cells[x][y])
	finalize_rep(width, height)

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
		configure_cell(repo,x,y,up,left)
#		print("ac: ", x, ' ', y)
		x = x + 1
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
	cell.position = Vector2((x*cell_size) as int, (y*cell_size) as int)
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

func put_player(xs, ys):
	$Player.visible = true
	var cellsize = Cell.instance().get_size()
	var cellsize_2 = cellsize / 2
	$Player.position = Vector2(xs * cellsize + cellsize_2, ys * cellsize + cellsize_2)

func put_goal(xf, yf):
	$Goal.visible = true
	var cellsize = Cell.instance().get_size()
	var cellsize_2 = cellsize / 2
	$Goal.position = Vector2(xf * cellsize + cellsize_2, yf * cellsize + cellsize_2)

enum PrimaStageAttribute {Inside, Outside, Border}

func generate_prima(dim):
	var width = dim.x
	var height = dim.y
	var rep = make_array_of_cells(width, height)
	rep = make_repo_with_all_walls(dim, rep)
	var attribute_array = []
	attribute_array.resize(width * height)
	var array_size = (dim.x * dim.y) as int
	var random_index = randi() % array_size
	var index = array_size - 1
	while index >= 0:
		attribute_array[index] = PrimaStageAttribute.Outside
		index = index - 1
	attribute_array[random_index] = PrimaStageAttribute.Inside
	change_attribute_for_neighbours(PrimaStageAttribute.Border, PrimaStageAttribute.Outside, random_index, dim, attribute_array)
	var shall_generate = true
	while shall_generate:
		var has_border_result = has_border(attribute_array)
		if has_border_result is bool and has_border_result == false:
			shall_generate = false
		else:
			var border_indexes = has_border_result[1]
			random_index = randi() % border_indexes.size()
			print("progress: ", border_indexes.size() / (dim.x * dim.y) * 100)
			var random_location_index = border_indexes[random_index]
			attribute_array[random_location_index] = PrimaStageAttribute.Inside
			change_attribute_for_neighbours(PrimaStageAttribute.Border, PrimaStageAttribute.Outside, random_location_index, dim, attribute_array)
			var dest_neighbour = get_random_destination_neighbour(random_location_index, dim, attribute_array)
			break_the_wall(get_coordinate_from_index(random_location_index, dim), dest_neighbour, rep)
	g_rep = [width, height, rep]
	emit_signal("on_generation_done")

func make_repo_with_all_walls(dim, rep):
	var width = dim.x
	var height = dim.y
	for x in range(0, width):
		for y in range(0, height):
			configure_cell(rep, x, y, true, true)
	return rep

func change_attribute_for_neighbours(new_attribute, required_attribute, index, dim, attribute_array):
	var location = get_coordinate_from_index(index, dim)
	for x in [location.x-1, location.x+1]:
		if x >= 0 and x < dim.x:
			var new_index = get_index_from_coord(Vector2(x, location.y), dim)
			if attribute_array[new_index] == required_attribute:
				attribute_array[new_index] = new_attribute
	for y in [location.y-1, location.y+1]:
		if y >= 0 and y < dim.y:
			var new_index = get_index_from_coord(Vector2(location.x, y), dim)
			if attribute_array[new_index] == required_attribute:
				attribute_array[new_index] = new_attribute

func get_coordinate_from_index(index, dim):
	var width = dim.x as int
	var x = (index as int) % width
	var y = (index / width) as int
	return Vector2(x,y)

func get_index_from_coord(coord, dim):
	return coord.y * (dim.x as int) + coord.x

func has_border(attribute_array):
	var result = false
	var available_indexes = []
	for i in attribute_array.size():
		if attribute_array[i] == PrimaStageAttribute.Border:
			available_indexes.append(i)
			result = true
	if result:
		return [result, available_indexes]
	else:
		return false

func get_random_destination_neighbour(location_index, dim, attribute_array):
	var matching_array_with_inside = []
	var current_coordinate = get_coordinate_from_index(location_index, dim)
	for x in [current_coordinate.x - 1, current_coordinate.x + 1]:
		if x >= 0 and x < dim.x:
			var local_index = get_index_from_coord(Vector2(x, current_coordinate.y), dim)
			if attribute_array[local_index] == PrimaStageAttribute.Inside:
				matching_array_with_inside.append(local_index)
	for y in [current_coordinate.y - 1, current_coordinate.y + 1]:
		if y >= 0 and y < dim.y:
			var local_index = get_index_from_coord(Vector2(current_coordinate.x, y), dim)
			if attribute_array[local_index] == PrimaStageAttribute.Inside:
				matching_array_with_inside.append(local_index)
	var random_neighbour_index = randi() % matching_array_with_inside.size()
	var dest_coordinate = get_coordinate_from_index(matching_array_with_inside[random_neighbour_index], dim)
	return dest_coordinate

func break_the_wall(current, dest, rep):
	print("bw: ", current, " to ", dest)
	if current.x < dest.x:
		var cell = rep[dest.x][dest.y]
		var up = cell.is_top()
		cell.setup(up, false)
		rep[dest.x][dest.y] = cell
	elif current.x > dest.x:
		var cell = rep[current.x][current.y]
		var up = cell.is_top()
		cell.setup(up, false)
		rep[current.x][current.y] = cell
	elif current.y < dest.y:
		var cell = rep[dest.x][dest.y]
		var left = cell.is_left()
		cell.setup(false, left)
		rep[dest.x][dest.y] = cell
	else:
		var cell = rep[current.x][current.y]
		var left = cell.is_left()
		cell.setup(false, left)
		rep[current.x][current.y] = cell

func generate_kruskal(dim):
	var width = dim.x
	var height = dim.y
	var locations = dim.x * dim.y
	var rep = make_array_of_cells(width, height)
	rep = make_repo_with_all_walls(dim, rep)
	var array_for_random_walls = make_array_of_walls(width, height)
	var random_wall_index = 0
	while locations > 1:
		print("generation, completed: ", 100 - locations / (dim.x * dim.y) * 100)
		var random_wall = array_for_random_walls[random_wall_index]
		random_wall_index = random_wall_index + 1
		var locations_separated_by_wall = get_locations_separated_by_wall(random_wall)
		var first_location = locations_separated_by_wall[0]
		var second_location = locations_separated_by_wall[1]
		var repo = [width, height, rep]
		if not has_path(repo, first_location, second_location):
				break_the_wall(first_location, second_location, rep)
				locations = locations - 1
	g_rep = [width, height, rep]
	emit_signal("on_generation_done")

func make_array_of_walls(width, height):
	var result_array_of_walls = []
	var x = 0
	var y = 0
	for i in width*height:
		if x != 0:
			result_array_of_walls.append([Vector2(x,y), false]) #left
		if y != 0:
			result_array_of_walls.append([Vector2(x,y), true]) #up
		x = x + 1
		if x == width:
			x =  0
			y = y + 1
	result_array_of_walls.shuffle()
	return result_array_of_walls

func has_path(repo, from, to):
	return solve_maze_with_wave_tracing(repo, from.x, from.y, to.x, to.y)[0] == true

func get_locations_separated_by_wall(random_wall):
	var pos = random_wall[0]
	if random_wall[1] == true:
		return [Vector2(pos.x, pos.y - 1), Vector2(pos.x, pos.y)]
	else:
		return [Vector2(pos.x - 1, pos.y), Vector2(pos.x, pos.y)]