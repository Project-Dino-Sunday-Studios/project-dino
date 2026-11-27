extends Node3D

@export var fade_screen: Panel
var current_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_fade(true, 0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _fade(type: bool, dur: float):
	var fade_tween = create_tween()
	current_tween = fade_tween
	if (type):#fade in
		fade_screen.visible = true
		fade_screen.modulate.a = 1.0
		fade_tween.tween_property(fade_screen, "modulate:a", 0.0, dur)
		await fade_tween.finished
		fade_screen.visible = false
		pass
	else:#fade out
		fade_screen.visible = true
		fade_screen.modulate.a = 0.0
		fade_tween.tween_property(fade_screen, "modulate:a", 1.0, dur)
		pass

func _on_play_button_pressed() -> void:
		#load gameplay scene
	_fade(false, 0.5)
	await current_tween.finished
	get_tree().change_scene_to_file("res://explore.tscn")
	pass # Replace with function body.
	
func _on_quit_button_pressed() -> void:
	#quit game
	_fade(false, 0.5)
	await current_tween.finished
	get_tree().quit()
	pass # Replace with function body.
