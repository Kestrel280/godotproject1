extends Control


func _ready() -> void:
	Globals.debug_box = $DebugBox;


func _process(delta: float) -> void:
	$SpeedBox/SpeedLabel.text = "%.1f | %.1f | %.1f" % [Globals.player.xy_speed * Globals.INCHES_PER_METER, Globals.player.z_speed * Globals.INCHES_PER_METER, Globals.player.kinetic_energy];
