extends CanvasLayer

@export var leave_button: Button

func _setup_interaction(npc : NPC.NPCData):
	$DialogueBox/NamePanel/Name.text = npc.name
	$ChefRender.texture = npc.sprite
	$Background.texture = npc.background_sprite
	pass
	
func _ready() -> void:
	Events.start_interaction.connect(_start_interact)
	hide()

func _physics_process(_delta: float) -> void:
	#if Input.is_action_just_pressed("interact"):
		#_start_interact()
		#
	pass

func _start_interact(npc : NPC.NPCData):
	_setup_interaction(npc)
	_toggle_interact(true)
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
	
