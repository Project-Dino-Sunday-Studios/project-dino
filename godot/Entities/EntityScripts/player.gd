extends CharacterBody3D

@export var model: Node3D
@export var fishing_ray: RayCast3D
@export var fish_catcher: Area3D

var ROTATION_SPEED: float = 1.7
var MOVEMENT_SPEED: float = 4.6
var SPRINT_SPEED: float = 1.8
var speed_multiplier: float = 1
var max_stamina: float = 100

# Fishing Variables
var reel_strength: float = 2
var boost_power: float = 8
var boost_stamina: float = 5


func _ready() -> void:
	Global.current_player_state = Global.PlayerState.TRAVERSE


func _physics_process(delta: float) -> void:
	# Start fishing
	_handle_fishing()
	if Global.current_player_state == Global.PlayerState.FISH:
		return
	## Rotation inputs
	if Input.is_action_pressed("move_left"):
		model.rotate(global_basis.y, ROTATION_SPEED * speed_multiplier * delta)
	if Input.is_action_pressed("move_right"):
		model.rotate(global_basis.y, -ROTATION_SPEED * speed_multiplier * delta)
	## Forward/backward direction inputs
	if Input.is_action_pressed("move_up"):
		global_position += model.global_basis.z * MOVEMENT_SPEED * speed_multiplier * delta
	if Input.is_action_pressed("move_down"):
		global_position -= model.global_basis.z * MOVEMENT_SPEED * speed_multiplier * delta
	
	# Aiming state
	if Input.is_action_just_pressed("aim"):
		# Switch player state
		match Global.current_player_state:
			Global.PlayerState.TRAVERSE:
				Global.current_player_state = Global.PlayerState.AIM
			Global.PlayerState.AIM:
				Global.current_player_state = Global.PlayerState.TRAVERSE
	
	
	if Input.is_action_pressed("sprint"):
		speed_multiplier = SPRINT_SPEED
	else:
		speed_multiplier = 1


func _handle_fishing() -> void:
	if not fishing_ray:
		push_error("Fishing Ray is not assigned in the Player scene!")
		return
	if fishing_ray.is_colliding() and fishing_ray.get_collider() is EnvironmentFish:
		var current_fish: EnvironmentFish = fishing_ray.get_collider()
		if Input.is_action_just_pressed("fish"):
			current_fish.activate_fishing(self, max_stamina, reel_strength, boost_power, boost_stamina)
			Events.start_fishing.emit()
	
	#when finishing is complete
	if fish_catcher.has_overlapping_areas():
		#Global.current_player_state = Global.PlayerState.AIM
		fish_catcher.get_overlapping_areas()[0].queue_free()
		
		Global.current_player_state = Global.PlayerState.ARRANGE_INVENTORY
		var fish_type := Fish.FishType.values().pick_random() as Fish.FishType
		Events.catch_fish.emit(fish_type)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
