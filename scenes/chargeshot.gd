extends RigidBody3D


func _init() -> void:
	self.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC;
	self.freeze = true;


func _ready() -> void:
	body_entered.connect(_on_body_entered);


func _on_body_entered(body : Node):
	print(body);
	queue_free();
	

func launch(dir : Vector3, impulse : float):
	self.freeze = false;
	self.apply_impulse(dir * impulse);
	set_collision_layer_value(3, true);
	set_collision_mask_value(1, true);
