class_name QuestHolder

var MazeSolver = preload("res://code/MazeSolver.gd")

var enable_ = false
var doors_ = []
var keys_ = []
var dim_: Vector2
var rep_

func is_enabled():
	return enable_

func _init(maze, enable):
	dim_ = maze[0]
	rep_ = maze[1]
	enable_ = enable
	var maze_solver = MazeSolver.new(dim_, rep_)
	var start: Vector2 = Vector2.ZERO
	var end: Vector2 = Vector2(dim_.x - 1, dim_.y - 1)
	maze_solver.solve_maze_with_wave_tracing(start.x, start.y, end.x, end.y)
	# Take ~ center of trace
	var pos_center = maze_solver.marks_array_.size() / 2
	doors_.append(maze_solver.marks_array_[pos_center])
	put_key()


func put_key():
		# pretend that the door is closed and find an appropriate place for key
	print("Put door: ", doors_[0])
	var old_cell = rep_[doors_[0]]
	rep_[doors_[0]] = MazeGenerator.CellKind.CLOSE
	var maze_solver = MazeSolver.new(dim_, rep_)
	var inner_space = maze_solver.get_inner_space(0, 0)
	
	# put a key somewhere in the inner space
	var where = 0
	where = randi() % inner_space.size()
	print("Select inner space: ", where, " what ", inner_space[where])
	keys_.append(inner_space[where])
	
	# restore rep_
	rep_[doors_[0]] = old_cell
	pass
