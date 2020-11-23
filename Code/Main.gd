extends Node2D

export (PackedScene) var Maze

onready var MazeGenerator = load("res://code/MazeGenerator.gd")
var maze_generator: MazeGenerator = null
onready var configuration_ = $CanvasLayer/Configuration

func _on_Configuration_configuration_done():
	configuration_.hide()
	maze_generator = MazeGenerator.new(configuration_.get_dim())
	maze_generator.connect("generation_done", self, "_on_Generation_done")
	maze_generator.generate_prima()

func _on_Generation_done():
	maze_generator.disconnect("generation_done", self, "_on_Generation_done")
	$Maze.setup_maze(maze_generator.get_maze())
	maze_generator = null
	$Maze.show()

func _on_Maze_on_game_finished():
	configuration_.show()
