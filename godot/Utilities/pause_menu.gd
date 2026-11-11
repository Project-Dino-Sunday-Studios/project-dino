extends CanvasLayer

@export var resume_button: Button
@export var quit_button: Button


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	hide()


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()


func _toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	visible = !visible


func _on_resume_button_pressed() -> void:
	_toggle_pause()
	hide()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
