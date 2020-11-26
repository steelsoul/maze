extends Node2D

export (PackedScene) var Maze

onready var MazeGenerator = load("res://code/MazeGenerator.gd")
var maze_generator: MazeGenerator = null
onready var configuration_ = $CanvasLayer/Configuration
var thread: Thread = null

func _on_Configuration_configuration_done():
	configuration_.hide()
	maze_generator = MazeGenerator.new(configuration_.get_dim())
	maze_generator.connect("generation_done", self, "_on_Generation_done")
	
	thread = Thread.new()
	$CanvasLayer/InProgressLabel.show()
	thread.start(self, "generator_thread", [configuration_, maze_generator])

func generator_thread(data):
	var config = 	data[0]
	var gen	=		data[1]
	match config.get_algorythm():
		"kruskal": 	gen.generate_kruskal()
		"prima": 	gen.generate_prima()

func _on_Generation_done():
	maze_generator.disconnect("generation_done", self, "_on_Generation_done")
	$Timer.start()

func _on_Maze_on_game_finished():
	configuration_.show()

func _exit_tree():
	if thread != null:
		thread.wait_to_finish()

func _on_Maze_game_over():
	$Maze.hide()
	$Maze.cleanup()
	configuration_.show()

func _on_Timer_timeout():
	$Maze.setup_maze(maze_generator.get_maze())
	thread.wait_to_finish()
	thread = null
	maze_generator = null
	$CanvasLayer/InProgressLabel.hide()
	var dimensions = configuration_.get_dim() - Vector2(1,1)
	$Maze.setup_game(Vector2(0, 0), dimensions)
	$Maze.show()
