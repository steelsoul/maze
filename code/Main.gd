extends Node2D

export (PackedScene) var Maze

onready var MazeGenerator = load("res://code/MazeGenerator.gd")
onready var QueastHolder = load("res://code/QuestHolder.gd")

var maze_generator: MazeGenerator = null
var quest_holder: QuestHolder = null

onready var configuration_ = $CanvasLayer/Configuration

func _on_Configuration_configuration_done():
	configuration_.hide()
	maze_generator = MazeGenerator.new(configuration_.get_dim())
	maze_generator.connect("generation_done", self, "_on_Generation_done")

	$CanvasLayer/InProgressLabel.show()
	
	match configuration_.get_algorythm():
		"kruskal": 	maze_generator.generate_kruskal()
		"prima": 	maze_generator.generate_prima()

func _on_Generation_done():
	maze_generator.disconnect("generation_done", self, "_on_Generation_done")
	$Timer.start()

func _on_Maze_on_game_finished():
	configuration_.show()

func _on_Maze_game_over():
	$Maze.hide()
	$Maze.cleanup()
	configuration_.show()

func _on_Timer_timeout():
	quest_holder = QuestHolder.new(maze_generator.get_maze(), configuration_.is_quest_mode())
	$Maze.setup_maze(maze_generator.get_maze(), quest_holder)
	$CanvasLayer/InProgressLabel.hide()
	var start_point = Vector2.ZERO
	var goal_point = configuration_.get_dim() - Vector2(1,1)
	var night_mode = configuration_.is_night_mode()
	$Maze.setup_game(start_point, goal_point, night_mode)
	$Maze.show()
