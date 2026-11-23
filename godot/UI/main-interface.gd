extends CanvasLayer

@export var interaction_popup : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	Events.toggle_interacton_range.connect(_toggleInteractPopup)
	
	_toggleInteractPopup(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _toggleInteractPopup(s : bool):
	interaction_popup.visible = s
	pass
