class_name Fish
extends RigidBody2D

##Managing fish in inventory

enum FishType {
	TRILOBITE,
	PIKAIA,
	CALLICHIMAERA,
	MOYTHOMASIA,
	XENACANTHUS,
	OSTEOLEPIS,
}

@export var falling_speed : float = 120.0
@export var horizontal_speed : float = 200.0
@export var inventory_grid : InventoryGrid

@onready var collision: CollisionPolygon2D = $CollisionPolygon2D


var is_dragging: bool = false #State of dragging fish
var drag_offset: Vector2 = Vector2.ZERO #Fish center position - mouse position
var landing_pending: bool = false #Recording collision with another object

var occupied_cells: Array[Vector2i] = []
var footprint: Array[Vector2i] = [Vector2i.ZERO]
var fish_texture: Texture2D


func _ready() -> void:
	gravity_scale = 0.0 #Set gravity to 0
	freeze = true #Lock fish movement
	if fish_texture != null: #Control fish have a texture
		$Sprite2D.texture = fish_texture #Assign the texture at sprite
	
	#Resize correctly the fish with cellsize and create the collision polygon
	fit_sprite_to_cell(get_footprint_bounds(footprint), inventory_grid.cell_size)


#Start falling
func start_fall() -> void:
	freeze = false #Freezing off


func _physics_process(_delta: float) -> void:
	if is_dragging:
		global_position = drag_offset + get_global_mouse_position()
	
	if not freeze:
		var cell := inventory_grid.global_to_cell(global_position)
		if landing_pending:
			if inventory_grid.gridData.place_cells([cell]):
				occupied_cells.append(cell) #Append the occupied cell to array
				inventory_grid.queue_redraw() #For debug the grid
				freeze = true #Lock the fish
				global_position = inventory_grid.get_global_cell_center(cell)
				print("Fish placed", cell)
			else:
				print("Placment Reject", cell)
			
			landing_pending = false
		


#Function to resize correctly fish's sprite and his collision's shape
func fit_sprite_to_cell(bounds_in_cell: Vector2i, cell_size: int) -> void:
	#Convert cell space to pixel
	var new_pixel := bounds_in_cell * cell_size
	#Measure png size
	var sprite: Sprite2D = $Sprite2D #Reference to sprite
	var texture: Texture2D = sprite.texture #Get the sprite's texture
	var image: Image = texture.get_image() #Get the texture's image
	var rect: Rect2i = image.get_used_rect() #Get only the used rect about image
	
	if not rect.has_area(): #Rect control
		return
	
	#Check the center about rect
	var crop_center := Vector2(rect.size) / 2.0
	print("Rect center: ", crop_center)
	
	sprite.region_rect = Rect2(rect) #Set the rect in sprite proprerties
	sprite.region_enabled = true #Set region enabled
	
	var width_scale_ratio: float = float(new_pixel.x) / rect.size.x #New scale ratio for sprite
	var height_scale_ratio: float = float(new_pixel.y) / rect.size.y #New scale ratio for sprite
	
	var minimum_scale_ratio: float = min(width_scale_ratio, height_scale_ratio) #Save the minimum scale from x and Y
	
	sprite.scale = Vector2(minimum_scale_ratio, minimum_scale_ratio) #Set the new scale to sprite's scale
	
	var outline := get_sprite_outline(image, rect) #Get the sprite outliner
	
	print((outline[0][0] - crop_center) * minimum_scale_ratio)
	
	var packed := PackedVector2Array()
	
	for point in outline[0]:
		packed.append((point - crop_center) * minimum_scale_ratio)
	
	collision.polygon = packed


#Get the sprite outliner
func get_sprite_outline(image: Image, rect: Rect2i) -> Array[PackedVector2Array]:
	#Rect control
	if not rect.has_area():
		return []
	
	var mask: BitMap = BitMap.new() #Create a empty BitMap
	mask.create_from_image_alpha(image, 0.5) #Collect the colored pixel from image
	#Create an Array of polygon covering a rectangular portion of a BitMap
	var outline := mask.opaque_to_polygons(rect)
	
	return outline

#Control fish's velocity and movement
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var direction := Input.get_axis("ui_left" , "ui_right")
	state.linear_velocity = Vector2(direction * horizontal_speed, falling_speed)


#Manage click on fish
func _input(event: InputEvent) -> void:
	#Check the input event
	if not is_dragging:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var mouse_pos := collision.get_local_mouse_position()
		
			if Geometry2D.is_point_in_polygon(mouse_pos, collision.polygon):
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


#Get the fish's occupied cell (dimension of a fish)
func get_footprint_bounds(_footprint: Array[Vector2i]) -> Vector2i:
	var max_x := -1
	var max_y := -1
	
	for cell in _footprint:
		max_x = maxi(max_x, cell.x) #Update x
		max_y = maxi(max_y, cell.y) #Update y
		
	return Vector2i(max_x +1, max_y +1)


#Get anchor for fish
func get_cells_at_anchor(anchor: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for offset in footprint:
		cells.append(anchor + offset)
	
	return cells


func _on_body_entered(body: Node) -> void:
	if not freeze:
		if body.name == "InventoryFloor":
			landing_pending = true
