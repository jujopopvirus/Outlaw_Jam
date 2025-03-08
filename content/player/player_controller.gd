class_name PlayerControllerTPS
extends CharacterBody3D

@export var mouse_sensitivity : float = 0.8
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

@onready var camera_spring : Camera3D = $ThirdPersonCamera/Camera
@onready var camera : ThirdPersonCamera = $ThirdPersonCamera

enum PlayerState {
	FREEZE,
	MOVE,
	DEAD
}
var playerState : PlayerState = PlayerState.MOVE



var parent_rotations : Node3D

#region OnReady_Functions
func _ready() -> void:
	_reposition_player()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _reposition_player() -> void:
	if get_parent():
		global_transform.origin = Vector3(25, 5, 0)
#endregion

#region Physics_Functions
func get_movement_speed() -> int:
	return (SPEED * 2.5) if Input.is_action_pressed("move_sprint") else SPEED

func _physics_process(delta: float) -> void:
	
	match_attackstate()
	
	match playerState:
		PlayerState.MOVE:
			_ray_lookat()
			combat_inputs()
			_move_process(delta)
		PlayerState.FREEZE:
			pass

var attack_state : Array = ["IDLE", "PROJECTILE", "BEAM", "ULTIMATE"]
var reloading : bool = false
func match_attackstate() -> void:
	match attack_state:
		[1]:
			print("PROJECTILE")
		[2]:
			print("BEAM")
		[3]:
			print("ULTIMATE")
		_:
			pass

func combat_inputs() -> void:
	if not reloading:
		if Input.is_action_pressed("primary_attack"):
			attack_state = [1]
		elif Input.is_action_pressed("secondary_attack"):
			attack_state = [2]
		elif Input.is_action_just_pressed("ultimate"):
			attack_state = [3]
		else:
			attack_state = [0]


func _ray_lookat() -> void:
	$RayCast3D.rotation = camera._camera.rotation
	$RayCast3D.global_transform = camera._camera.global_transform
	if $RayCast3D.is_colliding():
		%point.global_transform.origin = $RayCast3D.get_collision_point()
	else:
		%point.global_transform.origin = $RayCast3D.global_transform * (Vector3.FORWARD * 100)

func _gravity_process(delta) -> void:
	if Input.is_action_pressed("move_elevate"):
		velocity.y += JUMP_VELOCITY * delta
	elif Input.is_action_pressed("move_lower"):
		velocity.y -= JUMP_VELOCITY * delta
	else:
		velocity.y = move_toward(velocity.y, 0, JUMP_VELOCITY)

func _move_process(delta) -> void:
	_gravity_process(delta)
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	direction = direction.rotated(Vector3.UP, camera.rotation.y)
	
	if direction:
		velocity.x = direction.x * get_movement_speed()
		velocity.z = direction.z * get_movement_speed()
	else:
		velocity.x = move_toward(velocity.x, 0, get_movement_speed())
		velocity.z = move_toward(velocity.z, 0, get_movement_speed())

	move_and_slide()

func _unhandled_input(event) -> void:
	if event.is_action("toggle_mouse_mode"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity * 0.001
		rotation.y = wrapf(rotation.y, 0.0, TAU)

#endregion
