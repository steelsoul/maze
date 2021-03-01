extends "res://addons/gut/test.gd"

var QuestHolderClass = load("res://code/QuestHolder.gd")


func test_QuestHolder_init():
	var rep = [3, 2, 3, 3, 2, 1, 3, 0, 3, 0, 1, 2, 0, 2, 0, 3, 0, 3, 0, 2, 3, 0, 1, 1, 1]
	var dim = Vector2(5, 5)
	var is_enabled = true
	var qh = QuestHolder.new([dim, rep], is_enabled)
	assert_eq(qh.rep_, rep, "Check rep")
	assert_eq(qh.dim_, dim, "Check dim")
	
	assert_false(qh.doors_.size() == 0, "Door isn't in place")
	assert_false(qh.doors_[0] == 0, "Door can't be in the begin")
	
	assert_false(qh.keys_.size() == 0, "There must be one key")
