extends Node


const GROUND_NORMAL_THRESHOLD : float = 0.7; # If y component of surface normal is above this value, treat is as a floor
const GROUND_FRICTION_STOP_SPEED_THRESHOLD = 0.5 / Globals.INCHES_PER_METER; # On ground, if speed less than this value, just set to 0
const INCHES_PER_METER : float = 39.3701;


var dt;
var onGround : bool; # Player is on ground
var outWishVel : Vector3; # Per-frame desired movement vector
var lastCol : KinematicCollision3D; # Most recent collision; typically set by move_and_slide(), but may also be set by custom movement logic
var player : Player;


func _init(_player : Player):
	player = _player;


func move(_dt : float) -> void:
	dt = _dt;
	outWishVel = Vector3(player.velocity);

	if onGround:
		if (player.get_real_velocity().slide(lastCol.get_normal()).y > 0) && (player.get_real_velocity().slide(lastCol.get_normal()).y > player.jumpImpulse): # sliding quickly up a gentle slope
			outWishVel = player.velocity.slide(lastCol.get_normal());
			Globals.debug_box.text = "SLIDING";
			_airMove();
		elif Input.is_action_pressed("jump") and _tryJump():
			Globals.debug_box.text = "JUMPING";
			_airMove();
		else:
			Globals.debug_box.text = "WALKING";
			_groundMove()
	else:
		if player.hooked:
			Globals.debug_box.text = "HOOKED";
			_airMoveHooked();
		else:	
			Globals.debug_box.text = "AIRMOVING";
			_airMove()

	outWishVel += player.get_gravity() * player.gravity_scale * dt;
	player.velocity = outWishVel;
	var collision = player.move_and_collide(player.velocity * dt, true); # TEST for collision, do not actually perform
	if collision:
		player.velocity = player.velocity.slide(collision.get_normal());
		if collision.get_normal().y > GROUND_NORMAL_THRESHOLD: onGround = true;
		lastCol = collision;
	else:
		onGround = false;
	
	# Do the movement
	if player.move_and_slide(): lastCol = player.get_last_slide_collision();
	onGround = onGround || player.is_on_floor();

	player.xy_speed = Vector2(player.velocity.x, player.velocity.z).length();
	player.z_speed = player.velocity.y;
	player.kinetic_energy = player.velocity.length_squared() / 2 + player.global_position.y * ProjectSettings.get_setting("physics/3d/default_gravity") * player.gravity_scale;
	
	return;


func _airMove():
	var curSpeedInInputDir = player.inputDir.dot(player.velocity);
	var maxSpeedToAdd = max(0, player.airSpeedCap - curSpeedInInputDir);
	var speedToAddInInputDir = clampf(player.airAccel * player.airSpeedCap * dt, 0.0, maxSpeedToAdd); # TODO multiplication by airSpeedCap should probably be an analog value
	outWishVel += speedToAddInInputDir * player.inputDir;


func _airMoveHooked():
	var hook_to_player_unit_vector = (player.position - player.hook_pos).normalized();

	# If we're along the surface of the hook's sphere of influence:
	if player.position.distance_squared_to(player.hook_pos) > player.hook_lensq:
	# 	(1) keep player from exceeding range of hook
	# 	(2) Slide the movement vector along the surface of the sphere
	# 	(3) If sliding smoothly along the sphere, apply adjustment factor to preserve speed/avoid 
		player.position = player.hook_pos + hook_to_player_unit_vector * player.hook_len; # (1)
		var sqPreAdjustSpeed = outWishVel.length_squared();
		outWishVel = outWishVel.slide(hook_to_player_unit_vector); # (2)
		var sqSpeedLossRatio = outWishVel.length_squared() / sqPreAdjustSpeed;
		if sqSpeedLossRatio > 0.95: outWishVel /= sqrt(sqSpeedLossRatio); # (3)


func _groundMove() -> void:
	_applyGroundFriction(); # Apply friction, updating outWishVel
	_applyGroundAccel();	# Apply ground acceleration, updating outWishVel
	

func _applyGroundFriction() -> void:
	var wishSpeed = outWishVel.length();
	if wishSpeed < GROUND_FRICTION_STOP_SPEED_THRESHOLD:
		outWishVel = Vector3.ZERO;
		return;
	var speedScale = 1 - (player.groundFriction * dt);
	outWishVel = outWishVel * speedScale;


func _applyGroundAccel() -> void:
	var curSpeedInInputDir = player.inputDir.dot(player.velocity);
	var maxSpeedToAddInInputDir = player.groundSpeedCap - curSpeedInInputDir;
	var speedToAddInInputDir = clampf(player.groundAccel * player.groundSpeedCap * dt, 0.0, maxSpeedToAddInInputDir);  # TODO multiplication by groundSpeedCap should probably be an analog value
	outWishVel += speedToAddInInputDir * player.inputDir;
	

func _tryJump() -> bool:
	print("JUMP ", player.velocity)
	outWishVel.y = player.jumpImpulse;
	return true;
