extends Control


func _process(delta: float) -> void:
	$SpeedBox/SpeedLabel.text = "%.1f | %.1f" % [Globals.player.xy_speed / 0.0254, Globals.player.z_speed / 0.0254];
