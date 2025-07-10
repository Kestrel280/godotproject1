class_name Weapon extends Resource


@export_subgroup("Aesthetics")
@export var model : PackedScene;
@export var shoot_sound_path : String;
@export_subgroup("Properties")
@export_range(1.0, 100.0) var ammo : int = 10;
@export_range(0.05, 2.0) var shot_interval : float = 0.2;
@export var single_shot : bool = false;
@export var shoot_script : GDScript;


var _loaded;
var shoot_script_instance : Node;
var in_shot_recovery : bool = false;


func _load():
	_loaded = true;
	shoot_script_instance = shoot_script.new()


func try_shoot(shooter : CharacterBody3D):
	if (!_loaded): _load();
	if in_shot_recovery: return
	shoot_script_instance.shoot(shooter);
	in_shot_recovery = true;
	await shooter.get_tree().create_timer(shot_interval).timeout
	in_shot_recovery = false;


func stop_shoot(shooter : CharacterBody3D):
	if (!_loaded): _load();
	if shoot_script_instance.has_method("stop_shoot"): shoot_script_instance.stop_shoot(shooter);


func abort_shoot(shooter : CharacterBody3D):
	if (!_loaded): _load();
	if shoot_script_instance.has_method("abort_shoot"): shoot_script_instance.abort_shoot(shooter);
