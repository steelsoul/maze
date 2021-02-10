extends Node

class_name LevelCreator

var MazeGenerator = preload("res://code/MazeGenerator.gd")

# key: position of the key
# value: position of the door
var solution: Dictionary

func _init(maze):
	# Based on the maze size there are different amount of doors.
	# Every door requires its own key to be opened.
	# The keys are collected by the player
	var dim = maze[0]
	var rep = maze[1]
	var perimeter = 2 * (dim.x + dim.y)
	var n_doors = 0
	# ~10 - 1
	# ~20 - 2
	# ~80 - 4
	# ~240- 6
	if perimeter < 10: n_doors = 1
	elif perimeter < 20: n_doors = 2
	elif perimeter < 80: n_doors = 4
	else: n_doors = 6

