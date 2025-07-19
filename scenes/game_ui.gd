extends Control


signal unpaused;


func _ready() -> void:
	Globals.debug_box = $DebugBox;


func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("pause") and Globals.paused:
			get_viewport().set_input_as_handled();
			Globals.paused = false;
			unpaused.emit();


func _process(delta: float) -> void:
	$SpeedBox/SpeedLabel.text = "%.1f | %.1f | %.1f" % [Globals.player.xy_speed * Globals.INCHES_PER_METER, Globals.player.z_speed * Globals.INCHES_PER_METER, Globals.player.kinetic_energy];
