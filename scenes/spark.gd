extends Node3D


@export_range(0.1, 5.0) var decay_time = 2.0;
@export_range(0.0, 100.0) var start_vertical_speed = 10.0;
@export_range(0.0, 100.0) var end_vertical_speed = 0.0;
@export_range(0.0, 10.0) var start_luminescence = 5.0;
@export_range(0.0, 10.0) var end_luminescence = 0.0;


var time_passed : float = 0;


func _on_kill_timer_timeout():
	queue_free();


func _ready() -> void:
	var kill_timer = Timer.new();
	kill_timer.timeout.connect(_on_kill_timer_timeout);
	self.add_child(kill_timer);
	kill_timer.start(decay_time);
	$Light.light_energy = start_luminescence;


func _process(delta: float) -> void:
	time_passed += delta;
	var frac = time_passed / decay_time;
	$Light.light_energy = lerp(start_luminescence, end_luminescence, frac);
	self.position.y += lerp(start_vertical_speed, end_vertical_speed, frac) * delta;
	$Mesh.scale = Vector3(1 - frac, 1 - frac, 1 - frac);
