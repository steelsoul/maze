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

func test_MazeSolver_applyDirection():
	var point = Vector2(1, 1)
	var dl = maze_solver_.apply_direction(point, MazeSolver.Dir.LEFT)
	assert_eq(dl, Vector2(0, 1))
	var dr = maze_solver_.apply_direction(point, MazeSolver.Dir.RIGHT)
	assert_eq(dr, Vector2(2, 1))
	var du = maze_solver_.apply_direction(point, MazeSolver.Dir.UP)
	assert_eq(du, Vector2(1, 0))
	var dd = maze_solver_.apply_direction(point, MazeSolver.Dir.DOWN)
	assert_eq(dd, Vector2(1, 2))
	var p2 = Vector2(4, 1)
	var dl1 = maze_solver_.apply_direction(p2, MazeSolver.Dir.LEFT)
	assert_eq(dl1, Vector2(3,1))
	
func test_MazeSolver_solve():
	var start = Vector2(0, 0)
	var finish = Vector2(4, 4)
	var result = maze_solver_.solve_maze_with_wave_tracing(start.x, start.y, finish.x, finish.y)
	assert_eq(result, true, "Solver has to solve the maze")
	var marks_array = maze_solver_.marks_array_
	assert_false(marks_array.size() < 5, "Solution has more than 5 steps")
	var solution = maze_solver_.get_solution(finish)
	for idx in range(solution.size() - 1):
		var cur = solution[idx]
		var next = solution[idx+1]
		var dir = MazeSolver.Dir.LEFT
		var cur_pos = maze_solver_.translate2coord(cur)
		var next_pos = maze_solver_.translate2coord(next)
		var diff = next_pos - cur_pos
		var x_changed = (diff.x != 0)
		var y_changed = (diff.y != 0)
		var both_changed = x_changed and y_changed
		assert_eq(both_changed, false)
		if x_changed:
			var x_changed_1 = abs(diff.x) == 1
			assert_eq(x_changed_1, true)
		else:
			assert_eq(abs(diff.y), 1)
	assert_eq(solution.back(), 24)

func test_MazeSolver_getInnerSpace():
	var start = Vector2(0, 0)
	var finish = Vector2(4, 4)
	maze_solver_.solve_maze_with_wave_tracing(start.x, start.y, finish.x, finish.y)
	var solution = maze_solver_.get_solution(finish)
	var middle_idx = solution.size() / 2
	var starting_inner_space = maze_solver_.get_inner_space(start.x, start.y)
	
	var mod_rep = maze_rep_
	var dim = Vector2(5,5)
	mod_rep[middle_idx] = MazeGenerator.CellKind.CLOSE
	var solver1 = MazeSolver.new(dim, mod_rep)
	var new_inner_space = solver1.get_inner_space(start.x, start.y)
	
	assert_false(new_inner_space.empty())
	assert_false(starting_inner_space.empty())
	assert_gt(starting_inner_space.size(), new_inner_space.size(), "New inner space shall be less than initial one!")
	
