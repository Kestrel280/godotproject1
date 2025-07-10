extends Node


var pauseMenuScenePacked = preload("res://scenes/pause_menu.tscn");
var pauseMenuScene;


func _ready() -> void:
	_on_game_ui_unpaused();


func _on_player_paused() -> void:
	pauseMenuScene = pauseMenuScenePacked.instantiate();
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	get_tree().paused = true;
	add_child(pauseMenuScene); # Replace with function body.


func _on_game_ui_unpaused() -> void:
	get_tree().paused = false;
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	if pauseMenuScene: pauseMenuScene.queue_free();
