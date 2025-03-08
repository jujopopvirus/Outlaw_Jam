extends SpringArm3D

#@export var mouse_sensitivity : float = 0.8
#
#func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#rotation.y -= event.relative.x * mouse_sensitivity * 0.001
		#rotation.x -= event.relative.y * mouse_sensitivity * 0.001
