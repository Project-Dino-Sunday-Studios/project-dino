extends RigidBody2D

##Managing fish in inventory

@export var falling_speed : float = 120.0
@export var horizontal_speed : float = 200.0

var is_dragging: bool = false #State of dragging fish
var drag_offset: Vector2 = Vector2.ZERO #Fish center position - mouse position


func _ready() -> void:
	gravity_scale = 0.0 #Set gravity to 0
	freeze = true #Lock fish movement


#Start falling
func start_fall() -> void:
	freeze = false #Freezing off


func _physics_process(_delta: float) -> void:
	if is_dragging:
		global_position = drag_offset + get_global_mouse_position()



#Control fish's velocity and movement
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var direction := Input.get_axis("ui_left" , "ui_right")
	state.linear_velocity = Vector2(direction * horizontal_speed, falling_speed)


#Manage click on fish
func _input(event: InputEvent) -> void:
	#Check the input event
	if not is_dragging:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var collision : CollisionShape2D = $CollisionShape2D
			var rectangle := collision.shape as RectangleShape2D
			var bounds := Rect2(-rectangle.size / 2.0, rectangle.size)
		
			if bounds.has_point(collision.get_local_mouse_position()):
				print("Fish clicked")
				is_dragging = true
				drag_offset = global_position - get_global_mouse_position() #Calculate click point
				freeze = true #Freezing on (gravity off)
	else:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			print("Fish released")
			global_position = drag_offset + get_global_mouse_position() #Update mouse position
			is_dragging = false
			start_fall() #Unlock the fish movement
