class_name QuestHolder

var MazeSolver = preload("res://code/MazeSolver.gd")

var doors_ = []
var keys_ = []
var dim_: Vector2
var rep_

func _init(dim, rep):
	dim_ = dim
	rep_ = rep
	var maze_solver = MazeSolver.new(rep_, dim_)
	var start: Vector2 = Vector2.ZERO
	var end: Vector2 = Vector2(dim_.x - 1, dim_.y - 1)
	maze_solver.solve_maze_with_wave_tracing(start.x, start.y, end.x, end.y)
	# Take ~ center of trace
	var pos_center = maze_solver.marks_array_.size / 2
	doors_.append(maze_solver.marks_array_[pos_center])
	# pretend that the door is closed and find an appropriate place for key
	
	pass

func put_key():
	pass
