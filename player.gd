extends CharacterBody3D

@export var mass = 70;
@export var maxGroundVel = 30;
@export var groundAccel = 10;
@export var airFriction = 0.1;
@export var groundFriction = 5;
@export var jumpImpulse = 4;
var MOUSE_SENSITIVITY = 0.006; # TODO move to a globals/settings

var rot_x = 0	# Cumulative rotation
var rot_y = 0	# Cumulative rotation
var wishdir;
var dt;

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	velocity = Vector3.ZERO;
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	return;

func _physics_process(delta: float) -> void:
	dt = delta;

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	wishdir = ($Pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	_playerMove();

	move_and_slide()

func _playerMove() -> void:
	if not is_on_floor():
		_airMove();
	else:
		_groundMove();
		if Input.is_action_pressed("jump"):
			_jump()
	return;


func _airMove() -> void:
	velocity += get_gravity() * dt;
	velocity = velocity - (velocity * airFriction * dt);


func _groundMove() -> void:
	velocity += (wishdir * groundAccel) * dt;
	velocity = velocity - (velocity * groundFriction * dt);
	velocity.clampf(-maxGroundVel, maxGroundVel);


func _jump() -> void:
	velocity.y += jumpImpulse;


func _input(event):
	if event is InputEventMouseMotion:
		_handleMouseMotionEvent(event);


func _handleMouseMotionEvent(event):
	rot_x -= event.relative.x * MOUSE_SENSITIVITY;
	rot_y -= event.relative.y * MOUSE_SENSITIVITY;
	rot_x = wrapf(rot_x, -PI, PI);
	rot_y = clampf(rot_y, -PI/2, PI/2);
	$Pivot.transform.basis = Basis();
	$Pivot.rotate_object_local(Vector3(0, 1, 0), rot_x);
	$Pivot/Camera.transform.basis = Basis();
	$Pivot/Camera.rotate_object_local(Vector3(1, 0, 0), rot_y);
