extends CanvasLayer

@export var leave_button: Button

func _setup_interaction(npc : NPC.NPCData):
	$DialogueBox/NamePanel/Name.text = npc.name
	$ChefRender.texture = npc.sprite
	$Background.texture = npc.background_sprite
	pass
	
func _ready() -> void:
	hide()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_start_interact()
		

func _start_interact():
	_toggle_interact(true)
	#_setup_interaction() <- include for parameter
	pass
	
func _toggle_interact(state: bool) -> void:
	visible = state
	
	if(visible):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_leave_button_pressed() -> void:
	hide()
	_toggle_interact(false)
	
