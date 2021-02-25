extends "res://addons/gut/test.gd"

var maze_rep_ = []
var maze_dim_ = Vector2(5, 5)
var maze_solver_: MazeSolver

func before_each():
	maze_rep_ = [3, 2, 3, 3, 2, 1, 3, 0, 3, 0, 1, 2, 0, 2, 0, 3, 0, 3, 0, 2, 3, 0, 1, 1, 1]
	maze_dim_ = Vector2(5, 5)
	maze_solver_ = MazeSolver.new(maze_dim_, maze_rep_)
	pass

func test_MazeSolver_init():
	maze_solver_.marks_array_ = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5]
	maze_solver_.init_marks()
	var sum = 0
	for x in maze_solver_.marks_array_:
		sum += x
	assert_eq(sum, 0)

func test_MazeSolver_solve():
	var result = maze_solver_.solve_maze_with_wave_tracing(0, 0, 4, 4)
	assert_eq(result, true, "Solver has to solve the maze")
	var marks_array = maze_solver_.marks_array_
	assert_false(marks_array.size() < 5, "Solution has more than 5 steps")
