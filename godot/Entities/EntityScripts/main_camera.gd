class_name MainCamera extends Camera3D

enum CameraMode {
	ATTACHED,
	DETACHED
}

@export var main_camera: Camera3D
@export var attached_camera_pivot: Marker3D
@export var attached_camera_location: Marker3D
@export var detached_camera_pivot: Marker3D
@export var detached_camera_location: Marker3D

var camera_movement_speed: float = 7.0
var camera_sensitivity_x: float = 0.001
var camera_sensitivity_y: float = 0.001
var camera_mode: CameraMode = CameraMode.DETACHED

# Accumulated camera rotations - x = x movement of mouse, which is used to rotate about the Y AXIS, vice versa for y
var attached_rotation_x: float = 0
var attached_rotation_y: float = 0
var detached_rotation_x: float = 0
var detached_rotation_y: float = 0



func _physics_process(delta: float) -> void:
	_smooth_move_to_location_marker(delta)


func _smooth_move_to_location_marker(delta: float):
	if camera_mode == CameraMode.DETACHED:
		main_camera.global_transform = main_camera.global_transform.interpolate_with(detached_camera_location.global_transform, delta * camera_movement_speed)
	
	if camera_mode == CameraMode.ATTACHED:
		main_camera.global_transform = main_camera.global_transform.interpolate_with(attached_camera_location.global_transform, delta * camera_movement_speed)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if camera_mode == CameraMode.DETACHED:
			detached_rotation_y += event.relative.y * camera_sensitivity_y
			detached_rotation_x += -event.relative.x * camera_sensitivity_x
			
			detached_camera_pivot.transform.basis = Basis()
			detached_camera_pivot.rotate_x(detached_rotation_y) # Rotate about the x axis
			detached_camera_pivot.rotate_y(detached_rotation_x) # Rotate about the y axis
		
		if camera_mode == CameraMode.ATTACHED:
			attached_rotation_y += -event.relative.y * camera_sensitivity_y
			attached_rotation_x += -event.relative.x * camera_sensitivity_x
			
			attached_camera_pivot.transform.basis = Basis()
			attached_camera_pivot.rotate_x(attached_rotation_y) # Rotate about the x axis
			attached_camera_pivot.rotate_y(attached_rotation_x) # Rotate about the y axis
