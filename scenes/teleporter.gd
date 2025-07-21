extends Area3D

@export var destination : Node3D = Node3D.new();
@export var preserve_xy_velocity : bool = true;
@export var preserve_z_velocity : bool = true;
@export var add_velocity : Vector3 = Vector3.ZERO;
@export var set_view_angle : bool;


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
	if add_velocity:
		character.velocity += (destination.transform.basis.x * add_velocity) / Globals.INCHES_PER_METER;
	if set_view_angle:
		if character.has_method("set_view_angle_by_look_vector"):
			character.set_view_angle_by_look_vector(destination.transform.basis.x);
