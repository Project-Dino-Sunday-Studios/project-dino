class_name Inventory

extends Control

##Script for manage inventory

@onready var inventory_grid: InventoryGrid = $VBoxContainer/HBoxContainer/InventoryZone/InventoryGrid
const FISH_SCENE := preload("res://Scenes/fish.tscn")

#function that plays when you successfully catch a fish
func _catched_a_fish(fish : Fish.FishType):
	show()
	spawn_fish(fish)
	
func _complete_arrangement():
	await get_tree().create_timer(1.0).timeout
	hide()
	Global.current_player_state = Global.PlayerState.TRAVERSE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	Events.catch_fish.connect(_catched_a_fish)
	Events.end_arranging_inventory.connect(_complete_arrangement)
	hide()
	pass

#Debug Input
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_spawn_fish"):
		var fish_type := Fish.FishType.values().pick_random() as Fish.FishType
		spawn_fish(fish_type)


#Function for spawn a fish in inventory
func spawn_fish(type: Fish.FishType) -> void:
	#Spawn a fish
	var fish = FISH_SCENE.instantiate() as Fish
	
	#Match a fish's type and assign texture and dimension
	match type:
		Fish.FishType.TRILOBITE:
			fish.fish_texture = load("res://Assets/UI/Fish/Trilobite.png") as Texture2D
			fish.footprint.assign([Vector2i(0,0)])
			
		Fish.FishType.PIKAIA:
			fish.fish_texture = load("res://Assets/UI/Fish/pikaia.png") as Texture2D
			fish.footprint.assign([Vector2i(0,0), Vector2i(1,0), Vector2i(1,1)])
			
		Fish.FishType.CALLICHIMAERA:
			fish.fish_texture = load("res://Assets/UI/Fish/Callichimaera.png") as Texture2D
			fish.footprint.assign([Vector2i(0,0)])
		
		Fish.FishType.MOYTHOMASIA:
			fish.fish_texture = load("res://Assets/UI/Fish/moythomasia.png") as Texture2D
			fish.footprint.assign([Vector2i(0,0), Vector2i(1,0)])
			
		Fish.FishType.XENACANTHUS:
			fish.fish_texture = load("res://Assets/UI/Fish/Xenacanthus.png") as Texture2D
			fish.footprint.assign([Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)])
			
		Fish.FishType.OSTEOLEPIS:
			fish.fish_texture = load("res://Assets/UI/Fish/osteolepis.png") as Texture2D
			fish.footprint.assign([Vector2i(0,0), Vector2i(1,0)])
	
	fish.inventory_grid = inventory_grid
	add_child(fish)
	_show_fish_visual(fish)
	#fish.global_position = $VBoxContainer/HBoxContainer/RearrageZone.get_global_rect().get_center()

func _show_fish_visual(fish: Fish):
	#making fish appearing tween
	fish.can_drag = false
	fish.global_position = get_global_rect().get_center()
	var target = $VBoxContainer/HBoxContainer/RearrageZone.get_global_rect().get_center()
	var fish_tween = create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC)
	fish.scale = Vector2.ZERO
	var background = $TransparencyBackground
	background.modulate.a = 0.8
	
	fish_tween.tween_property(fish, "scale", Vector2.ONE, 0.5)
	fish_tween.tween_await(get_tree().create_timer(1.5).timeout)
	fish_tween.tween_property(fish, "global_position", target, 1.0)
	fish_tween.set_parallel()
	fish_tween.tween_property(background, "modulate:a", 0.0, 1.0)
	await fish_tween.finished
	fish.can_drag = true
	pass
