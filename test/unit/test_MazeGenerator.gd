extends "res://addons/gut/test.gd"

var MazeGeneratorClass = load("res://code/MazeGenerator.gd")

func before_all():
	gut.p("Runs once before all tests")

func before_each():
	gut.p("Runs before each test.")

func after_each():
	gut.p("Runs after each test.")

func after_all():
	gut.p("Runs once after all tests")

func test_MazeGenerator_init():
	var mg = MazeGenerator.new(Vector2(5, 3))
	assert_eq(mg.dimension_, Vector2(5,3), "Check dimension - 5x3")
	assert_false(mg.rep_.empty(), "Representation isn't empty")
	assert_eq(mg.rep_.size(), 15, "There are 15 items")
	assert_true(mg.marks_array_.empty(), "No marks")

func test_MazeGenerator_break_the_wall():
	var mg = MazeGenerator.new(Vector2(3, 3))
	mg.rep_ = [2, 2, 2, 0, 3, 1, 0, 2, 0]
	assert_eq(mg.rep_[mg.translate2index(1,1)], 3)
	mg.break_the_wall(Vector2(1, 0), Vector2(1,1))
	assert_eq(mg.rep_[mg.translate2index(1,1)], 1)
	mg.break_the_wall(Vector2(0, 1), Vector2(1,1))
	assert_eq(mg.rep_[mg.translate2index(1,1)], 0)
	mg.break_the_wall(Vector2(2, 1), Vector2(1,1))
	assert_eq(mg.rep_[mg.translate2index(2,1)], 0)
	mg.break_the_wall(Vector2(1, 2), Vector2(1,1))
	assert_eq(mg.rep_[mg.translate2index(1,2)], 0)
