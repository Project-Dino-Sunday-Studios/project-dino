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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"): 
		isPlayerInside = true
		print("player in area")
	
func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		isPlayerInside = false
		print("player left area")
