extends CharacterBody3D

# Movement parameters
@export var move_speed: float = 30.0  # Increased walking speed
@export var sprint_speed: float = 40.0  # Increased sprint speed
@export var acceleration: float = 15.0
@export var deacceleration: float = 10.0
@export var bobbing_amplitude: float = 0.10  # Reduced amplitude for less noticeable bobbing
@export var bobbing_speed: float = 12.0  # Slightly faster bobbing
@onready var crosshair = $CanvasLayer/TextureRect
# Movement variables
var is_sprinting: bool = false

# Bobbing variables
var bobbing_offset: float = 0.0
var bobbing_time: float = 0.0
var original_camera_height: float
var initial_player_height: float  # Store the player's starting Y height

# Reference to camera
var camera: Camera3D = null  # Reference to the camera for movement direction

func _ready():
	# Find the Camera3D node
	camera = $PlayerCamera  # Adjust this path if the hierarchy is different
	original_camera_height = camera.position.y  # Store the initial camera height for bobbing
	crosshair.visible=false
	# Store the player's starting height (Y-axis)
	initial_player_height = position.y

func _physics_process(delta):
	var input_direction = Vector3.ZERO

	# Get the camera's orientation basis for movement
	var camera_basis = camera.transform.basis

	# Project the camera's forward and right vectors onto the XZ plane
	var camera_forward = -camera_basis.z
	camera_forward.y = 0
	camera_forward = camera_forward.normalized()

	var camera_right = camera_basis.x
	camera_right.y = 0
	camera_right = camera_right.normalized()

	# Accumulate input direction based on WASD keys, relative to the camera's orientation
	if Input.is_key_pressed(KEY_W):
		input_direction += camera_forward  # Move forward in the direction the camera is facing
	if Input.is_key_pressed(KEY_S):
		input_direction -= camera_forward  # Move backward relative to the camera
	if Input.is_key_pressed(KEY_A):
		input_direction -= camera_right    # Move left relative to the camera
	if Input.is_key_pressed(KEY_D):
		input_direction += camera_right    # Move right relative to the camera

	# Ensure diagonal movement works smoothly by normalizing after accumulating all inputs
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()

	# Sprint toggle (optional, using Shift key for sprinting)
	is_sprinting = Input.is_key_pressed(KEY_SHIFT)  # Shift key for sprinting

	# Calculate target speed
	var target_speed = move_speed
	if is_sprinting:
		target_speed = sprint_speed

	# Smoothly accelerate towards target speed
	var target_velocity = input_direction * target_speed
	velocity = velocity.lerp(target_velocity, acceleration * delta)

	# Move the player using `move_and_slide`
	move_and_slide()

	# Lock the player's Y-axis to their initial height
	position.y = initial_player_height  # Lock the Y position to the starting height

	# Handle walking bobbing effect
	if input_direction != Vector3.ZERO:  # Only bob when the player is moving
		bobbing_time += bobbing_speed * delta
		bobbing_offset = sin(bobbing_time) * bobbing_amplitude
	else:
		# Reset bobbing when player stops
		bobbing_time = 0.0
		bobbing_offset = 0.0

	# Apply bobbing effect to the camera height
	camera.position.y = original_camera_height + bobbing_offset
