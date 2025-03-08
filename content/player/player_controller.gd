class_name PlayerControllerTPS
extends CharacterBody3D

@export var mouse_sensitivity : float = 0.8
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

@onready var camera_spring : Camera3D = $ThirdPersonCamera/Camera
@onready var camera : ThirdPersonCamera = $ThirdPersonCamera

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
func _physics_process(delta: float) -> void:
	_ray_lookat()
	_move_process(delta)

func _ray_lookat() -> void:
	$RayCast3D.rotation = camera._camera.rotation
	$RayCast3D.global_transform = camera._camera.global_transform
	if $RayCast3D.is_colliding():
		%point.global_transform.origin = $RayCast3D.get_collision_point()
	else:
		%point.global_transform.origin = $RayCast3D.global_transform * (Vector3.FORWARD * 100)

func _move_process(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	direction = direction.rotated(Vector3.UP, camera.rotation.y)
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _unhandled_input(event) -> void:
	if event.is_action("toggle_mouse_mode"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity * 0.001
		rotation.y = wrapf(rotation.y, 0.0, TAU)

#endregion
