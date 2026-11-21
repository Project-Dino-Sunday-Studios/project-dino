class_name EnvironmentFish
extends Interactable

enum FishState {
	IDLE,
	FISHING
}

@export var fish_boost: PackedScene

var current_player: CharacterBody3D
var reel_speed: float = 2
var default_reel_speed: float = reel_speed
var reel_strafe_speed: float = 3
var target_position: Vector3

var boost_interval: float = 2.5
var boost_spacing: float = 2.3
var boost_power: float = 2.4
var boost_dampening: float = 3

@onready var current_state: FishState = FishState.IDLE


func _physics_process(delta: float) -> void:
	if current_state == FishState.FISHING:
		if not current_player:
			push_error("Player is not defined for fishing!!")
			return
		look_at(target_position)
		global_position = global_position.move_toward(target_position, reel_speed * delta)
		if Input.is_action_pressed("move_left"):
			global_position += global_basis.x.normalized() * reel_strafe_speed * delta
		if Input.is_action_pressed("move_right"):
			global_position += -global_basis.x.normalized() * reel_strafe_speed * delta
	
	if has_overlapping_areas():
		var got_boost: FishBoost = get_overlapping_areas()[0]
		got_boost.queue_free()
		reel_speed *= boost_power
	reel_speed = move_toward(reel_speed, default_reel_speed, boost_dampening*delta)


func activate_fishing(player: CharacterBody3D) -> void:
	current_state = FishState.FISHING
	current_player = player
	Global.current_player_state = Global.PlayerState.FISH
	target_position = current_player.global_position - Vector3(0, 1, 0)
	look_at(target_position)
	
	var num_boosts: int = int(global_position.distance_to(player.global_position) / boost_interval)
	print(num_boosts, global_position.distance_to(player.global_position))
	for i in range(1, num_boosts+1):
		var boost: FishBoost = fish_boost.instantiate()
		add_child(boost)
		boost.global_position = global_position + (-global_basis.z * i * boost_spacing)
		boost.global_position += global_basis.x.normalized() * randf_range(-3, 3)
	print("start fishing")
