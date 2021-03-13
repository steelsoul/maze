extends Node2D

export (PackedScene) var Maze

onready var MazeGenerator = load("res://code/MazeGenerator.gd")
onready var QueastHolder = load("res://code/QuestHolder.gd")

var maze_generator: MazeGenerator = null
var quest_holder: QuestHolder = null

onready var configuration_ = $CanvasLayer/Configuration
signal generation_updated

func _on_Configuration_configuration_done():
	configuration_.hide()
	maze_generator = MazeGenerator.new(configuration_.get_dim())
	maze_generator.connect("generation_done", self, "_on_Generation_done")
	maze_generator.connect("generation_progress", self, "_on_Generation_progress")

	$CanvasLayer/InProgressLabel.show()
	$GenerationTimer.start()
	
	match configuration_.get_algorythm():
		"kruskal": 	maze_generator.generate_kruskal(self)
		"prima": 	maze_generator.generate_prima(self)

func _on_Generation_done():
	maze_generator.disconnect("generation_done", self, "_on_Generation_done")
	maze_generator.disconnect("generation_progress", self, "_on_Generation_progress")
	$GenerationTimer.stop()
	$Timer.start()

func _on_Generation_progress():
	if maze_generator != null:
		$CanvasLayer/InProgressLabel.visible = !$CanvasLayer/InProgressLabel.visible
		$GenerationTimer.start()

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
	var has_fog = configuration_.has_fog()
	$Maze.setup_game(start_point, goal_point, night_mode, has_fog)
	if $CanvasLayer/Configuration.is_hucontrol():
		$Maze.enable_input_layer()
	$Maze.show()
	maze_generator = null

func _on_GenerationTimer_timeout():
	emit_signal("generation_updated")
