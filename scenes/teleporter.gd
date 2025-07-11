extends Area3D

@export var destination : Node3D = Node3D.new();
@export var preserve_xy_velocity : bool = true;
@export var preserve_z_velocity : bool = true;
@export var set_view_angle : bool;
@export_range(-180, 180) var set_view_right_deg : float;
@export_range(-89, 89) var set_view_up_deg : float;


func _ready() -> void:
	if (!$Skin.mesh): $Skin.mesh = $TriggerVolume.shape.get_debug_mesh(); # if instantiator hasn't provided an override for mesh, give it the hitbox's
	if (!$Skin.material_override): $Skin.material_override = StandardMaterial3D.new();


func _on_body_entered(character: CharacterBody3D) -> void:
	character.global_position = destination.global_position;
	if !preserve_xy_velocity:
		character.velocity.x = 0;
		character.velocity.z = 0;
	if !preserve_z_velocity:
		character.velocity.y = 0;
	if set_view_angle:
		if character.has_method("set_view_angle"):
			character.set_view_angle(deg_to_rad(set_view_right_deg), deg_to_rad(set_view_up_deg));
