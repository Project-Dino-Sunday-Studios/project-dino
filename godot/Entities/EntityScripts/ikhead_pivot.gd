extends Node3D

@export var PIVOT_CAP_X : float = 20.0
@export var PIVOT_CAP_Y : float = 75.0

@export var detached_cam_pivot : Node3D
@export var attached_cam_pivot : Node3D
var active_camera : Node3D

@export var model : Node3D
var model_rotation : float
var rotation_difference : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	active_camera = detached_cam_pivot
	pass 

func _process(delta: float) -> void:
		#gathers rotation of camera vs. model
	var camera_rot = active_camera.basis.get_euler()
	var model_rot = model.basis.get_euler()
		#subtract rotation of model from camera 
	var diff = camera_rot - model_rot
		#clamping values so they dont go beyond desire pivot
	diff.x = clamp(diff.x, deg_to_rad(-PIVOT_CAP_X), deg_to_rad(PIVOT_CAP_X))
	diff.y = clamp(diff.y, deg_to_rad(-PIVOT_CAP_Y), deg_to_rad(PIVOT_CAP_Y))
	var target_angle = Vector3(diff.x, diff.y, diff.z)
	
	rotation.y = lerp_angle(rotation.y, target_angle.y, 5.0 * delta)
