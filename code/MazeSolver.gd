extends Node

class_name MazeSolver

var MazeGenerator = load("res://code/MazeGenerator.gd")

var marks_array_ 	= []
var dimension_ 		= Vector2.ZERO
var rep_			= []

enum Dir {LEFT, RIGHT, DOWN, UP}

func _init(dimension, rep):
	dimension_ = dimension
	rep_ = rep
	init_marks()
	pass

func get_inner_space(xs, ys):
	init_marks()
	var n_iter = 1
	
	while true:
		var x = 0
		var no_further_steps = true
		while x < dimension_.x:
			var y = 0
			while y < dimension_.y:
				if marks_array_[translate2index(x,y)] == n_iter:
					for dir in Dir.values():
						if can_go(x, y, dir):
							no_further_steps = false
							mark_neighbour(x, y, dir, n_iter + 1)
				y = y + 1
			x = x + 1
		n_iter = n_iter + 1
		if no_further_steps: 
			break
			
	return marks_array_

func solve_maze_with_wave_tracing(xs, ys, xf, yf):
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
						if can_go(x, y, dir):
#							print("can go ", describe(dir),  " from (", x, ",", y, ") on iter ", n_iter)
							no_further_steps = false
							mark_neighbour(x, y, dir, n_iter + 1)
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
		
func translate2index(x, y):
	return MazeGenerator.get_index_from_coord(Vector2(x,y), dimension_)

func translate2coord(index):
	return MazeGenerator.get_coordinate_from_index(index, dimension_)

func can_go(x, y, dir):
	var w = dimension_.x
	var h = dimension_.y
	match dir:
		Dir.LEFT:
			return x > 0 && !is_left(x,y) && marks_array_[translate2index(x-1,y)] == 0
		Dir.RIGHT:
			return x < w-1 && !is_left(x+1,y) && marks_array_[translate2index(x+1,y)] == 0
		Dir.UP:
			return y > 0 && !is_top(x,y) && marks_array_[translate2index(x,y-1)] == 0
		Dir.DOWN:
			return y < h-1 && !is_top(x,y+1) && marks_array_[translate2index(x,y+1)] == 0

func mark_neighbour(x, y, dir, n_iter):
	match dir:
		Dir.LEFT:  marks_array_[translate2index(x-1,y)] = n_iter
		Dir.RIGHT: marks_array_[translate2index(x+1,y)] = n_iter
		Dir.UP:    marks_array_[translate2index(x,y-1)] = n_iter
		Dir.DOWN:  marks_array_[translate2index(x,y+1)] = n_iter

func check_finish(x, y, xf, yf, dir):
	var xn = x
	var yn = y
	match dir:
		Dir.LEFT:  xn -= 1
		Dir.RIGHT: xn += 1
		Dir.UP:    yn -= 1
		Dir.DOWN:  yn += 1
	return xf == xn and yf == yn

func is_left(x, y):
	var idx = translate2index(x,y)
	return rep_[idx] == MazeGenerator.CellKind.HAS_LEFT || rep_[idx] == MazeGenerator.CellKind.CLOSE

func is_top(x, y):
	var idx = translate2index(x,y)
	return rep_[idx] == MazeGenerator.CellKind.HAS_UP || rep_[idx] == MazeGenerator.CellKind.CLOSE
