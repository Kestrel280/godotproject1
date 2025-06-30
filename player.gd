extends CharacterBody3D

const INCHES_PER_METER : float = 39.3701;
const GROUND_NORMAL_THRESHOLD : float = 0.7; # If y component of surface normal is above this value, treat is as a floor
const GROUND_SLIDE_THRESHOLD : float = 0.1; # Dot product of velocity + collision normal; if under this value, project velocity onto ground plane

@export var groundFriction = 4;
@export var mass = 70;

@export var jumpImpulse = 4;
@export var airAccel = 150;
@export var airSpeedCap = 30 / INCHES_PER_METER;
@export var groundFrictionStopSpeedThreshold = 0.5 / INCHES_PER_METER; # On ground, if speed less than this value, just set to 0
@export var groundAccel = 5; # Ground acceleration
@export var groundSpeedCap = 320 / INCHES_PER_METER; # Max walking speed on ground
var MOUSE_SENSITIVITY = 0.004; # TODO move to a globals/settings

var rot_x = 0	# Cumulative rotation
var rot_y = 0	# Cumulative rotation
var onGround : bool;
var inputDir : Vector3;
var outWishVel : Vector3;
var dt;

func _ready() -> void:
	velocity = Vector3.ZERO;
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	return;

func _physics_process(delta: float) -> void:
	dt = delta;

	var _inputDir2d = Input.get_vector("move_left", "move_right", "move_forward", "move_backward");
	inputDir = ($Pivot.transform.basis * Vector3(_inputDir2d.x, 0, _inputDir2d.y)).normalized();
	_playerMove();


func _playerMove() -> void:
	outWishVel = Vector3(velocity);
	outWishVel += get_gravity() * dt;
	
	if onGround:
		if Input.is_action_pressed("jump") and _tryJump():
			_airMove();
		else:
			_groundMove()
	else:
		_airMove();
		
	velocity = outWishVel;
	var collision = move_and_collide(velocity * dt, true); # TEST for collision, do not actually perform
	if collision:
		var severity = abs(velocity.normalized().dot(collision.get_normal())); # 0-1: higher = more severe collision
		velocity = velocity.slide(collision.get_normal());
		onGround = collision.get_normal().y > GROUND_NORMAL_THRESHOLD;
	else:
		onGround = false;
	move_and_slide()

	Globals.playerSpeedXy = Vector2(velocity.x, velocity.z).length();
	Globals.playerSpeedZ = velocity.y;
	
	return;


func _airMove() -> void:
	_applyAirAccel();


func _applyAirAccel():
	var curSpeedInInputDir = inputDir.dot(velocity);
	var maxSpeedToAdd = max(0, airSpeedCap - curSpeedInInputDir);
	var speedToAddInInputDir = clampf(airAccel * airSpeedCap * dt, 0.0, maxSpeedToAdd); # TODO multiplication by airSpeedCap should probably be an analog value
	outWishVel += speedToAddInInputDir * inputDir;


func _groundMove() -> void:
	_applyGroundFriction(); # Apply friction, updating outWishVel
	_applyGroundAccel();	# Apply ground acceleration, updating outWishVel
	

func _applyGroundFriction() -> void:
	var wishSpeed = outWishVel.length();
	if wishSpeed < groundFrictionStopSpeedThreshold:
		outWishVel = Vector3.ZERO;
		return;
	var speedScale = 1 - (getGroundFriction() * dt);
	outWishVel = outWishVel * speedScale;


func _applyGroundAccel() -> void:
	var curSpeedInInputDir = inputDir.dot(velocity);
	var maxSpeedToAddInInputDir = groundSpeedCap - curSpeedInInputDir;
	var speedToAddInInputDir = clampf(groundAccel * groundSpeedCap * dt, 0.0, maxSpeedToAddInInputDir);  # TODO multiplication by groundSpeedCap should probably be an analog value
	outWishVel += speedToAddInInputDir * inputDir;
	

func _tryJump() -> bool:
	outWishVel.y = jumpImpulse;
	return true;


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

func getGroundFriction() -> float:
	return groundFriction;
