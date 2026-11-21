extends CharacterBody3D

@export var model: Node3D
@export var fishing_ray: RayCast3D

var ROTATION_SPEED: float = 1.7
var MOVEMENT_SPEED: float = 4.6


func _ready() -> void:
	Global.current_player_state = Global.PlayerState.TRAVERSE


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
	
	# Aiming state
	if Input.is_action_just_pressed("aim"):
		# Switch player state
		match Global.current_player_state:
			Global.PlayerState.TRAVERSE:
				Global.current_player_state = Global.PlayerState.AIM
			Global.PlayerState.AIM:
				Global.current_player_state = Global.PlayerState.TRAVERSE
	
	# Start fishing
	_handle_fishing()


func _handle_fishing() -> void:
	if not fishing_ray:
		push_error("Fishing Ray is not assigned in the Player scene!")
		return
	if(fishing_ray.is_colliding() and fishing_ray.get_collider() is EnvironmentFish):
		var current_fish: EnvironmentFish = fishing_ray.get_collider()
		if Input.is_action_just_pressed("fish"):
			current_fish.activate_fishing()
			Events.start_fishing.emit()
