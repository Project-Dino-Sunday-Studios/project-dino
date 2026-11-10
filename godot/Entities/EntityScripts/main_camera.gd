class_name MainCamera extends Camera3D

@export var main_camera: Camera3D
@export var camera_location_marker: Marker3D

var camera_speed: float = 7.0

func _physics_process(delta: float) -> void:
	_smooth_move_to_location_marker(delta)


func _smooth_move_to_location_marker(delta: float):
	main_camera.global_transform = main_camera.global_transform.interpolate_with(camera_location_marker.global_transform, delta * camera_speed)
