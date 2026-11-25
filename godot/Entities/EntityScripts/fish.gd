class_name EnvironmentFish
extends RigidBody3D

enum FishState {
	IDLE,
	FISHING
}

@export var reel_collision: CollisionShape3D
@export var fish_boost: PackedScene
@export var fish_boost_detector: Area3D
@export var capture_detector: Area3D

var current_player: CharacterBody3D
var reel_strafe_speed: float = 3
var target_position: Vector3
var direction_to_target_position: Vector3

var boost_interval: float = 2.5
var boost_spacing: float = 2.3
var constant_velocity_dampening: float = .7

## Player fishing variables
var reel_power: float = -1
var boost_power: float = -1


@onready var current_state: FishState = FishState.IDLE


func _ready() -> void:
	fish_boost_detector.area_entered.connect(
		func(boost):
			if boost is FishBoost:
				var got_boost: FishBoost = boost
				got_boost.queue_free()
				activate_boost()
	)
	
	capture_detector.area_entered.connect(
		func(_fish_catcher):
			Global.current_player_state = Global.PlayerState.AIM
			end_fishing()
	)


func _physics_process(delta: float) -> void:
	if current_state == FishState.FISHING:
		if not current_player:
			push_error("Player is not defined for fishing!!")
			return
		look_at(target_position)
		direction_to_target_position = global_position.direction_to(target_position)
		
		#global_position = global_position.move_toward(target_position, reel_speed * delta)
		
		if Input.is_action_pressed("move_left"):
			global_position += global_basis.x.normalized() * reel_strafe_speed * delta
			rotation.y += deg_to_rad(-20)
		if Input.is_action_pressed("move_right"):
			global_position += -global_basis.x.normalized() * reel_strafe_speed * delta
			rotation.y += deg_to_rad(20)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if current_state == FishState.FISHING:
		if(reel_power == -1):
			assert(false, "Fish's reel power variable was never set from player's reel power!")
		
		## Reel in the fish, proportional to the player's reel power, inversely proportional to mass
		var constant_reeling_velocity: Vector3 = direction_to_target_position * reel_power * (1/mass)
		state.linear_velocity = state.linear_velocity.move_toward(constant_reeling_velocity, constant_velocity_dampening)


func activate_boost() -> void:
	if boost_power == -1:
		assert(false, "Fish's boost power variable was never set from player's boost power!")
	apply_central_impulse(direction_to_target_position * boost_power)


func activate_fishing(player: CharacterBody3D, reel_strength: float, boost_strength: float) -> void:
	if current_state == FishState.FISHING:
		return
	
	current_state = FishState.FISHING
	current_player = player
	capture_detector.process_mode = Node.PROCESS_MODE_INHERIT
	reel_power = reel_strength
	boost_power = boost_strength
	Global.current_player_state = Global.PlayerState.FISH
	
	target_position = current_player.global_position - Vector3(0, 0, 0)
	look_at(target_position)
	
	
	var num_boosts: int = int(global_position.distance_to(player.global_position) / boost_interval)
	for i in range(1, num_boosts+1):
		var boost: FishBoost = fish_boost.instantiate()
		add_child(boost)
		boost.global_position = global_position + (-global_basis.z * i * boost_spacing)
		boost.global_position += global_basis.x.normalized() * randf_range(-3, 3)


func end_fishing() -> void:
	queue_free()
	# Signal for after fishing
