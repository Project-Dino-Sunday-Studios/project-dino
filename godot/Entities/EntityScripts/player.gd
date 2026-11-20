extends CharacterBody3D

@export var model: Node3D

var ROTATION_SPEED: float = 1.7
var MOVEMENT_SPEED: float = 4.6


func _physics_process(delta: float) -> void:
	## Rotation inputs
	if Input.is_action_pressed("move_left"):
		model.rotate(global_basis.y, ROTATION_SPEED * delta)
	if Input.is_action_pressed("move_right"):
		model.rotate(global_basis.y, -ROTATION_SPEED * delta)
	## Forward/backward direction inputs
	if Input.is_action_pressed("move_up"):
		global_position += model.global_basis.z * MOVEMENT_SPEED * delta
	if Input.is_action_pressed("move_down"):
		global_position -= model.global_basis.z * MOVEMENT_SPEED * delta
