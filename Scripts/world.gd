extends Node3D

@onready var pause_menu=$PauseMenu
@onready var player=$World/Player
@onready var camera = $World/Player/PlayerCamera
@onready var level=$World/Level
@onready var floor=$World/Level/Floor/CSGCylinder3D
@onready var crosshair=$World/Player/CanvasLayer/TextureRect
@onready var going_back=false
@export var doc_mgr_script :Resource=preload("res://Scripts/DocumentManager.gd")
@onready var explosion_scene:PackedScene =preload("res://Scenes/vfx_explosion.tscn")


var sphere_radius:float=4.0 #might change later if atoms become smaller/larger
var paused: bool = false
var fileExplorerDisplaying:bool=false
var allowed_spawn:bool =true

func _ready() ->void:
	camera.set_root(self)
	print("okay lets go world")
	crosshair.visible=true
	camera.rotation_degrees=Vector3(45,105,0)
	
	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and !going_back:  # This is typically mapped to the ESC key
		paused = !paused
		if pause_menu.getCurrentMenu()=="option":
			return;
		pause_menu.visible = paused
		if paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			crosshair.visible=false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			crosshair.visible=true
			
		
		camera.set_paused_state(paused)  # Notify the camera script of the pause state
		
	if Input.is_action_just_pressed("ui_select") and paused and !fileExplorerDisplaying: 
		fileExplorerDisplaying=true
		'''var outputs=await doc_mgr.read_zmat_from_files()
		var res=doc_mgr.convert_zmatrix_to_coordinates(outputs)
		for r in res.coordinates:
			print(r)
		print("Adjancies: ")
		for r in res.bonds:
			print(r)
		fileExplorerDisplaying=false'''
		
	if Input.is_action_just_pressed("pause") and fileExplorerDisplaying:
		fileExplorerDisplaying=false
	
	#making sure player doesnt go off bounds
	check_player_boundary()
	

func check_player_boundary() -> void:
	# Get player's position
	var player_pos: Vector3 = player.global_transform.origin

	# Get the distance from the origin (0,0,0)
	var distance_from_center: float = player_pos.length()

	# Get the radius of the floor (assuming it's the cylinder's radius)
	var floor_radius: float = floor.radius

	# If the player is outside the floor's radius, move them back to the edge
	if distance_from_center > floor_radius:
		# Normalize player's position to get the direction from the center
		var direction_from_center: Vector3 = player_pos.normalized()

		# Set the player's position to the edge of the floor (on the radius)
		player.global_transform.origin = direction_from_center * floor_radius
		
		
func _on_back_to_main_button_pressed() -> void:
	going_back=true
	$World/Player/CanvasLayer.visible=false
	
#called by the player's camera script when the object is released
func check_for_merge(released_object):
	print("checking for merge")
	for other_grabbable in get_tree().get_nodes_in_group("mergeable"):
		if other_grabbable != released_object:
			var dist=released_object.global_transform.origin.distance_to(other_grabbable.global_transform.origin)
			if dist <= sphere_radius:
				var midpoint= (released_object.global_transform.origin + other_grabbable.global_transform.origin)/2
				print("MERGE DETECTED, youre holding: ",released_object.name," merging with: ",other_grabbable.name)
				#remove the objects from existence :)
				var new_object = released_object.duplicate()
				new_object.name=released_object.name+""
				released_object.queue_free()
				other_grabbable.queue_free()
				
				#add explosion vfx 
				var explosion_instance=explosion_scene.instantiate()
				level.add_child(explosion_instance)
				explosion_instance.global_transform.origin=midpoint
				var scale_factor=lerp(1.0,10.0,clamp((self.global_transform.origin.distance_to(released_object.global_transform.origin)-5.0)/(50.0-5.0),0.0,1.0))
				for child in explosion_instance.get_children():
					child.scale=Vector3(scale_factor,scale_factor,scale_factor)
					child.emitting=true
				
				#wait for explosion to finish
				await get_tree().create_timer(0.37).timeout
			
				#create ew atom (sphere for now, maybe molecule later) at the midpoint of intersections
				level.add_child(new_object)
				new_object.global_transform.origin=midpoint
				new_object.get_node("aura").visible=false

				#clean up explosion instance
				explosion_instance.queue_free()
				#explosion_instance.queue_free()
				break


func spawn_molecule(mol : Node3D):
	mol.transform.origin=Vector3(15.0,15.0,15.0)
	level.add_child(mol)
