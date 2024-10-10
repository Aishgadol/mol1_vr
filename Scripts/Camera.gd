extends Camera3D

# Sensitivity of the mouse movement
var mouse_sensitivity: float = 0.1
var move_speed: float = 15.0
var is_paused:bool=false
var root :Node3D=null
var grabbed_object =null
var ray_cast:RayCast3D
var grab_distance:float=0.0
var aura=null

# Track the vertical rotation
var vertical_rotation: float = 0.0

#min/max distance 
var min_distance : float=8.0
var max_distance: float = 50.0


#colors
var white_color : Color = Color(1,1,1) #white
var yellow_color: Color = Color(1,1,0) #yellow
var time_passed :float =0.0  #auxiliry var to help with graduale aura color changing

func _ready():
	# Hide the mouse cursor and capture it
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ray_cast=$RayCast3D
	

func _process(delta):
	
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !is_paused :
		var collider=ray_cast.get_collider()
		if grabbed_object==null:
			#try to grab obj
			if collider:
				print(collider.name," , ",collider.get_groups())
				if collider.is_in_group("grabbable"):
					grabbed_object=collider
					grab_distance=(grabbed_object.global_transform.origin-global_transform.origin).length()
					var target_pos=global_transform.origin+global_transform.basis.z*-1*grab_distance
					grabbed_object.global_transform.origin=target_pos
					aura = grabbed_object.get_node("aura")
					if aura:
						aura.visible=true
					
					
		if grabbed_object!=null:
			#grab_distance=(grabbed_object.global_transform.origin-global_transform.origin).length()
			var target_pos=global_transform.origin+global_transform.basis.z*-1*grab_distance
			grabbed_object.global_transform.origin=target_pos
			#apply graduale color change using lerp and delta
			time_passed += delta * 10.0 # Use delta directly to affect the speed 
			#based on frame rate, multiply delta to make sin wave change in faster pace
			#chatgpt is stupid as a rock and this took me 2 hours
			var lerp_value = 0.5* (sin(time_passed) + 1.0)  # Result ranges from 0 to 1
			aura=grabbed_object.get_node("aura")
			if aura:
				for child in aura.get_children():
					child.mesh.material.albedo_color = white_color.lerp(yellow_color, lerp_value)
				
			
	#body is no longer held (LMB unheld)
	else:
		if grabbed_object:
			#check if object is intersecting with other objects in space
			#world script needs to handle the intersection logic
			root.check_for_merge(grabbed_object)
			#release obj if button isnt pressed
			#aura = grabbed_object.get_node("aura")
			if aura:
				aura.visible=false
			grabbed_object=null
			
func _on_Area3D_body_entered(body):
	#this func will be called when collision occurs
	print("collision")
	
	# Handle upward and downward movemen
func _input(event):
	if is_paused:
		return
		
	if event is InputEventMouseMotion:
		# Calculate new rotations based on mouse movement
		var mouse_delta = event.relative

		# Horizontal rotation (yaw)
		rotate_y(deg_to_rad(-mouse_delta.x * mouse_sensitivity))

		# Vertical rotation (pitch)
		vertical_rotation -= mouse_delta.y * mouse_sensitivity

		# Clamp the vertical rotation to avoid flipping
		vertical_rotation = clamp(vertical_rotation, -89.5, 89.5)
		rotation_degrees.x = vertical_rotation

	if grabbed_object and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			grab_distance+=1.0
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			grab_distance-=1.0
		#clamp stuff
		grab_distance=clamp(grab_distance,min_distance,max_distance)

func set_paused_state(paused: bool) -> void:
	is_paused = paused

func get_grabbed_object():
	return grabbed_object

func set_root(root):
	self.root=root
	return
