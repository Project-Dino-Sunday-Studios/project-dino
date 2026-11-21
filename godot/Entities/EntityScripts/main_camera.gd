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
@export var fishing_camera_location: Marker3D
@export var fishing_ray: RayCast3D
@export var crosshair: CenterContainer

var camera_movement_speed: float = 30.0
var camera_sensitivity_x: float = 0.001
var camera_sensitivity_y: float = 0.001
var aiming_sensitivity_x: float = 0.001
var aiming_sensitivity_y: float = 0.001
var camera_mode: CameraMode = CameraMode.DETACHED

# Accumulated camera rotations - x = x movement of mouse, which is used to rotate about the Y AXIS, vice versa for y
# [rotation_x, rotation_y] -- Using Array[float] here because I wanted to have pass-by-reference functionality to use the
# _handle_node_rotation_using_mouse function
var attached_rotations: Array[float] = [0.0, 0.0]
var detached_rotations: Array[float] = [0.0, 0.0]

var minimum_vertical_angle: float = deg_to_rad(-3)
var maximum_vertical_angle: float = deg_to_rad(80)

## fishing/aim variables
var in_fishing_pov: bool = false
var default_fishing_basis: Basis = Basis(Vector3(-1.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0), Vector3(0.0, 0.0, -1.0) )
var fishing_rotations: Array[float] = [0.0, 0.0]
var minimum_fishing_vertical_angle: float = deg_to_rad(-3)
var maximum_fishing_vertical_angle: float = deg_to_rad(50)
var minimum_fishing_horizontal_angle: float = deg_to_rad(-90)
var maximum_fishing_horizontal_angle: float = deg_to_rad(-5)

var fishing_distance: float = 12


func _ready() -> void:
	Events.start_fishing.connect(_start_fishing)
	fishing_ray.target_position = Vector3(0, 0, -fishing_distance)


func _physics_process(delta: float) -> void:
	#TODO: change these magic numbers
	if Global.current_player_state == Global.PlayerState.AIM:
		fov = 75
		if crosshair:
			crosshair.visible = true
		fishing_ray.process_mode = ProcessMode.PROCESS_MODE_INHERIT
	else: # Global.current_player_state == Global.PlayerState.TRAVERSE
		fov = 90
		if crosshair:
			crosshair.visible = false
		fishing_ray.process_mode = ProcessMode.PROCESS_MODE_DISABLED
	
	var tween: Tween = create_tween()
	if fishing_ray.is_colliding() and fishing_ray.get_collider() is EnvironmentFish:
		tween.tween_property(crosshair, "rotation", deg_to_rad(20), .04)
	else:
		tween.tween_property(crosshair, "rotation", 0, .04)
	
	_move_to_location_marker(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Global.current_player_state == Global.PlayerState.TRAVERSE:
			_handle_third_person_camera(event)
		else:
			fishing_rotations[0] = clamp(fishing_rotations[0], minimum_fishing_horizontal_angle, maximum_fishing_horizontal_angle)
			fishing_rotations[1] = clamp(fishing_rotations[1], minimum_fishing_vertical_angle, maximum_fishing_vertical_angle)
			
			_handle_node_rotation_using_mouse(event, null, fishing_camera_location, fishing_rotations, default_fishing_basis)

func _move_to_location_marker(delta: float):
	if Global.current_player_state == Global.PlayerState.TRAVERSE:
		if camera_mode == CameraMode.DETACHED:
			main_camera.global_transform = main_camera.global_transform.interpolate_with(detached_camera_location.global_transform, delta * camera_movement_speed)
		if camera_mode == CameraMode.ATTACHED:
			main_camera.global_transform = main_camera.global_transform.interpolate_with(attached_camera_location.global_transform, delta * camera_movement_speed)
	else:
		main_camera.global_transform = fishing_camera_location.global_transform


func _handle_third_person_camera(event: InputEvent) -> void:
	if camera_mode == CameraMode.DETACHED:
			detached_rotations[1] = clamp(detached_rotations[1], minimum_vertical_angle, maximum_vertical_angle)
			_handle_node_rotation_using_mouse(event, null, detached_camera_pivot, detached_rotations)
		
	if camera_mode == CameraMode.ATTACHED:
		_handle_node_rotation_using_mouse(event, null, attached_camera_pivot, attached_rotations)


func _handle_node_rotation_using_mouse(event: InputEvent, camera_location: Marker3D, camera_pivot: Marker3D, accumulated_rotations: Array[float], default_basis: Basis = Basis()) -> void:
	accumulated_rotations[0] += -event.relative.x * camera_sensitivity_x
	accumulated_rotations[1] += event.relative.y * camera_sensitivity_y
	
	camera_pivot.transform.basis = default_basis
	
	if camera_location:
		camera_location.rotate_x(accumulated_rotations[1]) # Rotate about the x axis
		camera_location.rotate_y(accumulated_rotations[0]) # Rotate about the y axis
	
	if camera_pivot:
		camera_pivot.rotate_x(accumulated_rotations[1]) # Rotate about the x axis
		camera_pivot.rotate_y(accumulated_rotations[0]) # Rotate about the y axis


func _start_fishing() -> void:
	#crosshair.rotation += deg_to_rad(20)
	var tween: Tween = create_tween()
	tween.tween_property(crosshair, "rotation", deg_to_rad(60), .04)
	tween.tween_property(crosshair, "rotation", deg_to_rad(0), .04)
