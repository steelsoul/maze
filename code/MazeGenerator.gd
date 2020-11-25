
class_name MazeGenerator

signal generation_progress
signal generation_done

var dimension_: Vector2
var rep_ = []
var marks_array_ = []

enum CellKind {OPEN = 0, HAS_LEFT = 1, HAS_UP = 2, CLOSE = 3}
enum PrimaStageAttribute {INSIDE, OUTSIDE, BORDER}
enum Dir {LEFT, RIGHT, DOWN, UP}

func _init(dimensions: Vector2):
	rep_.clear()
	marks_array_.clear()
	dimension_ = dimensions
	rep_.resize(dimension_.x * dimension_.y)

func generate_prima():
	fill_maze_with_walls()
	
	var attribute_array = []
	attribute_array.resize(dimension_.x * dimension_.y)

	var random_index = randi() % attribute_array.size()
	var index = attribute_array.size() - 1
	while index >= 0:
		attribute_array[index] = PrimaStageAttribute.OUTSIDE
		index = index - 1
		
	attribute_array[random_index] = PrimaStageAttribute.INSIDE
	change_attribute_for_neighbours(PrimaStageAttribute.BORDER, PrimaStageAttribute.OUTSIDE, random_index, attribute_array)

	while true:
		var border_result = has_border(attribute_array)
		if border_result.empty():
			break
		else:
			random_index = randi() % border_result.size()
#			print("progress: ", border_indexes.size() / (dim.x * dim.y) * 100)
			var random_location_index = border_result[random_index]
			attribute_array[random_location_index] = PrimaStageAttribute.INSIDE
			change_attribute_for_neighbours(PrimaStageAttribute.BORDER, PrimaStageAttribute.OUTSIDE, random_location_index, attribute_array)
			var dest_neighbour = get_random_destination_neighbour(random_location_index, attribute_array)
			break_the_wall(get_coordinate_from_index(random_location_index, dimension_), dest_neighbour)

	emit_signal("generation_done")

func fill_maze_with_walls():
	for x in range(0, dimension_.x):
		for y in range(0, dimension_.y):
			rep_[translate2index(x,y)] = CellKind.CLOSE
			
func change_attribute_for_neighbours(new_attribute, required_attribute, index, attribute_array):
	var location = get_coordinate_from_index(index, dimension_)
	for x in [location.x-1, location.x+1]:
		if x >= 0 and x < dimension_.x:
			var new_index = translate2index(x, location.y)
			if attribute_array[new_index] == required_attribute:
				attribute_array[new_index] = new_attribute
	for y in [location.y-1, location.y+1]:
		if y >= 0 and y < dimension_.y:
			var new_index = translate2index(location.x, y)
			if attribute_array[new_index] == required_attribute:
				attribute_array[new_index] = new_attribute

func get_coordinate_from_index(index, dim):
	var width = dim.x as int
	var x = (index as int) % width
	var y = (index / width) as int
	return Vector2(x,y)

static func get_index_from_coord(coord, dim):
	return coord.y * (dim.x as int) + coord.x

func translate2index(x, y):
	return get_index_from_coord(Vector2(x,y), dimension_)

func translate2coord(index):
	return get_coordinate_from_index(index, dimension_)
	
func has_border(attribute_array):
	var available_indexes = []
	for i in attribute_array.size():
		if attribute_array[i] == PrimaStageAttribute.BORDER:
			available_indexes.append(i)
	return available_indexes

func get_random_destination_neighbour(location_index, attribute_array):
	var matching_array_with_inside = []
	var current_coordinate = translate2coord(location_index)
	for x in [current_coordinate.x - 1, current_coordinate.x + 1]:
		if x >= 0 and x < dimension_.x:
			var local_index = translate2index(x, current_coordinate.y)
			if attribute_array[local_index] == PrimaStageAttribute.INSIDE:
				matching_array_with_inside.append(local_index)
	for y in [current_coordinate.y - 1, current_coordinate.y + 1]:
		if y >= 0 and y < dimension_.y:
			var local_index = translate2index(current_coordinate.x, y)
			if attribute_array[local_index] == PrimaStageAttribute.INSIDE:
				matching_array_with_inside.append(local_index)
	var random_neighbour_index = randi() % matching_array_with_inside.size()
	var dest_coordinate = translate2coord(matching_array_with_inside[random_neighbour_index])
	return dest_coordinate
	
func break_the_wall(current, dest):
	#print("bw: ", current, " to ", dest)
	if current.x < dest.x:
		rep_[translate2index(dest.x, dest.y)] &= 2
	elif current.x > dest.x:
		rep_[translate2index(current.x,current.y)] &= 2
	elif current.y < dest.y:
		rep_[translate2index(dest.x, dest.y)] &= 1
	else:
		rep_[translate2index(current.x,current.y)] &= 1

func generate_kruskal():
	var width = dimension_.x
	var height = dimension_.y
	var locations = width * height
	fill_maze_with_walls()
	var array_for_random_walls = make_array_of_walls(width, height)
	var random_wall_index = 0
	while locations > 1:
		#var progress = 80 - locations / (dim.x * dim.y) * 80 + 20
		#print("generation, completed: ", progress)
		#emit_signal("generation_progress", progress)
		var random_wall = array_for_random_walls[random_wall_index]
		random_wall_index = random_wall_index + 1
		var locations_separated_by_wall = get_locations_separated_by_wall(random_wall)
		var first_location = locations_separated_by_wall[0]
		var second_location = locations_separated_by_wall[1]
		if not has_path(first_location, second_location):
			break_the_wall(first_location, second_location)
			locations = locations - 1
	emit_signal("generation_done")

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
	
func get_locations_separated_by_wall(random_wall):
	var pos = random_wall[0]
	if random_wall[1] == true:
		return [Vector2(pos.x, pos.y - 1), Vector2(pos.x, pos.y)]
	else:
		return [Vector2(pos.x - 1, pos.y), Vector2(pos.x, pos.y)]

func has_path(from, to):
	return solve_maze_with_wave_tracing(rep_, from.x, from.y, to.x, to.y)

func solve_maze_with_wave_tracing(repo, xs, ys, xf, yf):
	init_marks()
	var n_iter = 1
	marks_array_[translate2index(xs,ys)] = n_iter

	while true:
		var x = 0
		var no_further_steps = true
		while x < dimension_.x:
			var y = 0
			while y < dimension_.y:
				if marks_array_[translate2index(x,y)] == n_iter:
					for dir in Dir.values():
						if can_go(repo, x, y, dir, marks_array_, 0):
#							print("can go ", describe(dir),  " from (", x, ",", y, ") on iter ", n_iter)
							no_further_steps = false
							mark_neighbour(marks_array_, x, y, dir, n_iter + 1)
							if check_finish(x, y, xf, yf, dir) == true:
								return true
				y = y + 1
			x = x + 1
		n_iter = n_iter + 1
		if no_further_steps: return false

func init_marks():
	marks_array_.clear()
	marks_array_.resize(dimension_.x * dimension_.y)
	for i in marks_array_.size():
		marks_array_[i] = 0

func get_result_path():
	return marks_array_

func can_go(rep, x, y, dir, marks_array, n_iter):
	var w = dimension_.x
	var h = dimension_.y
	match dir:
		Dir.LEFT:
			return x > 0 && !is_left(x,y) && marks_array[translate2index(x-1,y)] == n_iter
		Dir.RIGHT:
			return x < w-1 && !is_left(x+1,y) && marks_array[translate2index(x+1,y)] == n_iter
		Dir.UP:
			return y > 0 && !is_top(x,y) && marks_array[translate2index(x,y-1)] == n_iter
		Dir.DOWN:
			return y < h-1 && !is_top(x,y+1) && marks_array[translate2index(x,y+1)] == n_iter

func is_left(x, y):
	var idx = translate2index(x,y)
	return rep_[idx] == CellKind.HAS_LEFT || rep_[idx] == CellKind.CLOSE

func is_top(x, y):
	var idx = translate2index(x,y)
	return rep_[idx] == CellKind.HAS_UP || rep_[idx] == CellKind.CLOSE

func mark_neighbour(rep, x, y, dir, n_iter):
	match dir:
		Dir.LEFT:  rep[translate2index(x-1,y)] = n_iter
		Dir.RIGHT: rep[translate2index(x+1,y)] = n_iter
		Dir.UP:    rep[translate2index(x,y-1)] = n_iter
		Dir.DOWN:  rep[translate2index(x,y+1)] = n_iter

func check_finish(x, y, xf, yf, dir):
	var xn = x
	var yn = y
	match dir:
		Dir.LEFT:  xn -= 1
		Dir.RIGHT: xn += 1
		Dir.UP:    yn -= 1
		Dir.DOWN:  yn += 1
	return xf == xn and yf == yn

func get_maze():
	return [dimension_, rep_]
