extends Node

var playerScenePacked = preload("res://scenes/player.tscn");
var pauseMenuScenePacked = preload("res://scenes/pause_menu.tscn");
var pauseMenuScene;


func _ready() -> void:
	$GameUi.player_requested_map_load.connect(load_map);
	load_map("map1");
	_on_game_ui_unpaused();


func _on_player_paused() -> void:
	pauseMenuScene = pauseMenuScenePacked.instantiate();
	get_tree().paused = true;
	add_child(pauseMenuScene);
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);


func _on_game_ui_unpaused() -> void:
	if pauseMenuScene: pauseMenuScene.queue_free();
	get_tree().paused = false;
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);


func load_map(mapName : String):
	var mapPath : String = "res://maps/%s.tscn" % mapName;
	var mapScn : PackedScene = load(mapPath);
	
	# Clean up current world and player
	if Globals.world: Globals.world.queue_free();
	if Globals.player: Globals.player.queue_free();

	# Load new world and player
	var map = mapScn.instantiate();
	var player : Player = playerScenePacked.instantiate();
	add_child(map);
	add_child(player);
	
	if map.has_node("SpawnPoint"):
		player.global_transform = map.get_node("SpawnPoint").global_transform;
		player.set_view_angle(0, 0);
	
	player.paused.connect(_on_player_paused);
	
	# Register new world and player to globals
	Globals.world = map;
	Globals.player = player;
	return;
