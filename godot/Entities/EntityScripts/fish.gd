class_name EnvironmentFish
extends RigidBody3D

enum FishState {
	IDLE,
	FISHING,
	FAIL
}

@export var fish_mesh: MeshInstance3D
@export var reel_collision: CollisionShape3D
@export var fish_boost: PackedScene
@export var fish_boost_detector: Area3D
@export var capture_detector: Area3D
@export var fishing_UI: CanvasLayer
@export var stamina_bar: ProgressBar

var current_player: CharacterBody3D
var target_position: Vector3
var direction_to_target_position: Vector3

var boost_interval: float = 2.5
var boost_spacing: float = 2.3
var constant_velocity_dampening: float = .7
var stamina_drain_rate = 20

## Player fishing variables
var max_stamina: float = -1
var current_stamina: float = -1
var effective_reel_power: float = -1
var boost_power: float = -1
var boost_stamina: float = -1


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
			global_position += global_basis.x.normalized() * effective_reel_power * delta
		if Input.is_action_pressed("move_right"):
			global_position += -global_basis.x.normalized() * effective_reel_power * delta
		
		_change_stamina_bar(delta)
	
	elif current_state == FishState.FAIL:
		global_position = global_position.lerp(global_position - Vector3(0,10,0), delta*1.5)
		fish_mesh.lod_bias = lerp(fish_mesh.lod_bias, 0.0, delta*40)
		await get_tree().create_timer(.25).timeout
		queue_free()
		


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if current_state == FishState.FISHING:
		if(effective_reel_power == -1):
			assert(false, "Fish's reel power variable was never set from player's reel power!")
		
		## Reel in the fish, proportional to the player's reel power, inversely proportional to mass
		var constant_reeling_velocity: Vector3 = direction_to_target_position * effective_reel_power
		state.linear_velocity = state.linear_velocity.move_toward(constant_reeling_velocity, constant_velocity_dampening)


func _change_stamina_bar(delta: float) -> void:
	current_stamina -= stamina_drain_rate * delta
	stamina_bar.value = current_stamina
	
	if stamina_bar.value <= 0:
		current_state = FishState.FAIL


func _set_up_UI() -> void:
	stamina_bar.max_value = max_stamina

func activate_boost() -> void:
	if boost_power == -1 or boost_stamina == -1:
		assert(false, "One of Fish's boost variables was never set from player's boost power!")
	apply_central_impulse(direction_to_target_position * boost_power)
	current_stamina += boost_stamina


func activate_fishing(player: CharacterBody3D, player_max_stamina: float, reel_strength: float, boost_strength: float, boost_stamina_gain: float) -> void:
	if current_state == FishState.FISHING:
		return
	
	current_state = FishState.FISHING
	Global.current_player_state = Global.PlayerState.FISH
	capture_detector.process_mode = Node.PROCESS_MODE_INHERIT
	fishing_UI.visible = true
	current_player = player
	max_stamina = player_max_stamina
	current_stamina = max_stamina
	boost_power = boost_strength
	boost_stamina = boost_stamina_gain
	
	_set_up_UI()
	effective_reel_power = reel_strength * 1/mass ## Make effective reel power inversely proportional to fish's mass
	
	target_position = current_player.global_position - Vector3(0, 0, 0)
	look_at(target_position)
	
	#TODO: Make fish dash away when the player hooks too close to the fish?
	
	var num_boosts: int = int(global_position.distance_to(player.global_position) / boost_interval)
	for i in range(1, num_boosts+1):
		var boost: FishBoost = fish_boost.instantiate()
		add_child(boost)
		boost.global_position = global_position + (-global_basis.z * i * boost_spacing)
		boost.global_position += global_basis.x.normalized() * randf_range(-3, 3)


func end_fishing() -> void:
	queue_free()
	# Signal for after fishing
