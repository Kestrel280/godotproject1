extends Node


var pauseMenuScenePacked = preload("res://scenes/pause_menu.tscn");
var pauseMenuScene;


func _ready() -> void:
	_on_game_ui_unpaused();


func _on_player_paused() -> void:
	pauseMenuScene = pauseMenuScenePacked.instantiate();
	get_tree().paused = true;
	#PhysicsServer3D.set_active(false);
	add_child(pauseMenuScene);
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);


func _on_game_ui_unpaused() -> void:
	if pauseMenuScene: pauseMenuScene.queue_free();
	get_tree().paused = false;
	#PhysicsServer3D.set_active(true);
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
