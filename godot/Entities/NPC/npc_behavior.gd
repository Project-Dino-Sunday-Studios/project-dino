extends Node3D
class_name NPC

#for passing into other information
class NPCData:
	var name : String
	var sprite : Texture2D
	var background_sprite : Texture2D
	
	func _init(n : String, s : Texture2D, bg : Texture2D) -> void:
		name = n
		sprite = s
		background_sprite = bg
		
@export var character_name : String
@export var character_sprite : Texture2D
@export var background_sprite : Texture2D

var isPlayerInside : bool = false

func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") && isPlayerInside:
		var npc = NPCData.new(character_name, character_sprite, background_sprite)
		Events.start_interaction.emit(npc)
		Events.toggle_interacton_range.emit(false)
		pass

func _on_interaction_area_body_entered(body: Node3D) -> void:
	isPlayerInside = true
	Events.toggle_interacton_range.emit(true)

func _on_interaction_area_body_exited(body: Node3D) -> void:
	isPlayerInside = false
	Events.toggle_interacton_range.emit(false)
