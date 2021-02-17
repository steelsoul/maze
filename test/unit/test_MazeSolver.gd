extends "res://addons/gut/test.gd"

func test_MazeSolver_init():
	var rep = [3, 2, 3, 3, 2, 1, 3, 0, 3, 0, 1, 2, 0, 2, 0, 3, 0, 3, 0, 2, 3, 0, 1, 1, 1]
	var dim = Vector2(5, 5)
	var ms = MazeSolver.new(dim, rep)
	ms.marks_array_ = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5]
	ms.init_marks()
	var sum = 0
	for x in ms.marks_array_:
		sum += x
	assert_eq(sum, 0)

func read_maze(input):
	input.find(",")
