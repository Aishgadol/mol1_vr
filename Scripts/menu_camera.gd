extends Camera3D

# Adjustable variables
var move_speed = 2.4  # Speed of movement (20% faster than 2.0)
var max_height = 20.0  # Maximum height above the starting position

# Internal variables
var direction = 1.0
var start_position: Vector3
var camera_moving=true

func _ready():
	# Save the starting position of the camera
	start_position = global_transform.origin

func _process(delta):
	if camera_moving:
		# Calculate the new position
		var new_position = global_transform.origin
		new_position.y += direction * move_speed * delta
		
		# Adjust the camera's pitch based on its height
		var height_difference = new_position.y - start_position.y
		var pitch_angle = lerp(0.0, -10.0, height_difference / max_height)
		rotation_degrees.x = pitch_angle
		
		# Check if the camera has reached the maximum height or the starting position
		if new_position.y >= start_position.y + max_height:
			direction = -1.0  # Start moving down
			new_position.y = start_position.y + max_height
		elif new_position.y <= start_position.y:
			direction = 1.0  # Start moving up
			new_position.y = start_position.y
		
		# Apply the new position to the camera
		global_transform.origin = new_position

# Helper function to linearly interpolate between two values
func lerp(a: float, b: float, t: float) -> float:
	return a + (b - a) * t


func _on_options_button_pressed() -> void:
	pass # Replace with function body.

#func to stop camera movement
func stop_camera_movement():
	camera_moving=false
