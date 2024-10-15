class_name DocumentManager
extends Node

@onready var entityManager:EntityManager=$EntityManager

@export var max_refresh_rate:int=90

var myCall:Callable=Callable(self, "_on_file_selected")
var file_dialog: FileDialog=null
var working_with:String=""
var loaded_info:String=""
var content_load_error:bool=false
var xr_interface:XRInterface
var xr_is_focused=false

signal file_dialog_done
signal done_reading_from_files
signal focus_lost
signal focus_gained
signal pose_recentered



var last_selected_filename:String=""
var script_path:String
var script_path_global:String

func _ready()->void:
	xr_interface=XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.initialize():
		print("OpenXR Interface initiatied succesfully")
		#disable vsync cuz vsync is handled by openxr
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		var vp:Viewport=get_viewport()
		#enable xr on viewport
		vp.use_xr=true
	#enable vrs
		if RenderingServer.get_rendering_device():
			vp.vrs_mode=Viewport.VRS_XR
		elif int(ProjectSettings.get_setting("xr/openxr/foveation_level"))==0:
			push_warning("OpenXR: recommend setting foveation level to high in project settings..")
		
		#connect the default OpenXR events
		xr_interface.session_begun.connect(_on_openxr_session_begun)
		xr_interface.session_visible.connect(_on_openxr_visible_state)
		xr_interface.session_focussed.connect(_on_openxr_focused_state)
		xr_interface.session_stopping.connect(_on_openxr_stopping)
		xr_interface.pose_recentered.connect(_on_openxr_pose_recentered)
	else:
		#OpenXR didnt open
		print("OpenXR not instantiated")
		get_tree().quit()
		
func run()->void:
	print("okay lets go doc mgr")
	script_path = "res://gc.py"
	script_path_global = ProjectSettings.globalize_path(script_path)
	if !FileAccess.file_exists(script_path_global):
		push_error("Python script 'gc.py' not found at path: %s" % script_path_global)
	else:
		print("Python script 'gc.py' found at path: %s" % script_path_global)
		
func _process(delta:float):
	if Input.is_action_just_pressed("importZmat"):
		script_path = "res://gc.py"
		script_path_global = ProjectSettings.globalize_path(script_path)
		if !FileAccess.file_exists(script_path_global):
			push_error("Python script 'gc.py' not found at path: %s" % script_path_global)
		else:
			print("Python script 'gc.py' found at path: %s" % script_path_global)
			
			
		#this segement is for "cleanup" before reading new file
		for child in get_children():
			if child.name.contains("File"):
				child.queue_free()
		loaded_info=""
		content_load_error=false
		
		
		open_file("zmat")
		await file_dialog_done
		
		if(loaded_info!=""):
			entityManager.newMol(convert_zmatrix_to_coordinates(loaded_info))
			
			
func read_zmat_from_files():
	open_file("zmat")
	await file_dialog_done
	emit_signal("done_reading_from_files")
	
func read_xyz_from_files()->String:
	open_file("xyz")
	await file_dialog_done
	return loaded_info
	
func open_file(type:String) -> void:
	working_with=type
	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	file_dialog.set_size(Vector2(400,300))
	if(type=="zmat"):
		file_dialog.filters = ["*.csv", "*.txt", "*.zmat"]
	elif(type=="xyz"):
		file_dialog.filters = ["*.csv", "*.txt", "*.xyz"]
	else:
		return
	
	var connected= file_dialog.connect("file_selected", Callable(self, "_on_file_selected"))
	
	if connected != OK:
		print("failed to connect FILE")
	add_child(file_dialog)
	file_dialog.popup_centered()

	
func _on_file_selected(file_path: String) -> void:
	last_selected_filename=file_path.get_file()
	var content = load_file_content(file_path)
	if(content_load_error):
		print("Invalid Z-matrix/XYZ format or no file selected.")
		loaded_info=""
		#file_dialog.queue_free()
		return
	if content != null:
		if working_with == "zmat" and is_valid_zmatrix(content):
			loaded_info=content
		elif working_with=="xyz" and is_valid_xyz(content):
			loaded_info=content
		else:
			print("Invalid Z-matrix/XYZ format or no file selected.")		
			loaded_info=""
	else:
		print("Invalid Z-matrix/XYZ format or no file selected.")
		loaded_info=""
	
	#file_dialog.queue_free()
	emit_signal("file_dialog_done")
	
func _on_file_dialog_closed(file_dialog):
	file_dialog.queue_free()
	
func load_file_content(file_path: String) -> String:
	var file_extension = file_path.get_extension().to_lower()
	if (file_extension != "csv" and file_extension != "txt" and file_extension != "zmat" and working_with=="zmat") or (file_extension != "csv" and file_extension != "txt" and file_extension != "zmat" and working_with=="xyz") or working_with=="":
			content_load_error=true
			return "Wrong File Format"
	var file = FileAccess.open(file_path,FileAccess.READ)
	if file != null:
		var content = file.get_as_text()
		file.close()
		return content
	else:
		content_load_error=true
		return ""

func is_valid_zmatrix(content: String) -> bool:
	var lines = content.strip_edges().split("\n", false)
	var line_count = 0
	for line in lines:
		line.replace("\r","")
		line = line.strip_edges()
		if line == "":
			continue  # Skip empty lines
		var tokens = line.split(" ",false)
		line_count += 1
		if line_count == 1:
			# First line should have one token
			if tokens.size() != 1:
				return false
		elif line_count == 2:
			# Second line should have three tokens
			if tokens.size() != 3:
				return false
		elif line_count == 3:
			# Third line should have five tokens
			if tokens.size() != 5:
				return false
		else:
			# Subsequent lines should have seven tokens
			if tokens.size() != 7:
				return false
	return true

func is_valid_xyz(content: String) -> bool:
	var lines = content.strip_edges().split("\n", false)
	var non_empty_lines = []
	
	# Remove carriage returns and strip edges
	for line in lines:
		line = line.replace("\r", "").strip_edges()
		if line == "":
			continue  # Skip empty lines
		non_empty_lines.append(line)
	
	var line_count = non_empty_lines.size()
	
	# There must be at least two lines: the atom count and the comment line
	if line_count < 2:
		return false
	
	# First line should be an integer representing the number of atoms
	var num_atoms_line = non_empty_lines[0]
	if not num_atoms_line.is_valid_integer():
		return false
	var num_atoms = int(num_atoms_line)
	if num_atoms < 1:
		return false  # Number of atoms should be positive
	
	# Total lines should be equal to num_atoms + 2 (atom count line + comment line + atom lines)
	if line_count != num_atoms + 2:
		return false
	
	# Iterate over atom lines and validate
	for i in range(2, line_count):
		var tokens0 = non_empty_lines[i].split(" ", false)
		var tokens=[]
		# Remove any empty tokens caused by multiple spaces
		for token in tokens0:
			if token!="":
				tokens.append(token)
				
		if tokens.size() != 4:
			return false
		var symbol = tokens[0]
		var x = tokens[1]
		var y = tokens[2]
		var z = tokens[3]
		# Validate that x, y, z are valid floating-point numbers
		if not x.is_valid_float() or not y.is_valid_float() or not z.is_valid_float():
			return false
	return true
	
func extract_bonds_from_zmatrix(content: String) -> Array:
	var bonds = []
	var lines = content.strip_edges().split("\n", false)
	var line_count = 0
	for line in lines:
		line = line.strip_edges()
		if line == "":
			continue  # Skip empty lines
		var tokens = line.split(" ", false)
		line_count += 1
		var current_atom_index = line_count - 1  # 0-based index
		if line_count == 1:
			# First atom has no bonds
			continue
		else:
			# Only consider the bond length index (tokens[1]) for bonding
			if tokens.size() >= 2:
				var connected_atom_index = int(tokens[1]) - 1  # Convert to 0-based index
				var bond = [min(current_atom_index, connected_atom_index), max(current_atom_index, connected_atom_index)]
				if bond not in bonds:
					bonds.append(bond)
	return bonds

#return {
#		"zmat": z_matrix_string,
#		"xyz": xyz_string,
#		"bonds": bonds
#	} --->
func convert_zmatrix_to_coordinates(z_matrix_string: String) -> Dictionary:
	var zmat_file_path = "user://temp_zmat.zmat"  # Path to store the Z-matrix
	
	# Write the Z-matrix string to a temporary file
	var zmat_file = FileAccess.open(zmat_file_path, FileAccess.WRITE)
	if zmat_file == null:
		push_error("Failed to write Z-matrix to temporary file.")
		return {}
	zmat_file.store_string(z_matrix_string)
	zmat_file.close()
	
	# Get absolute paths
	var zmat_file_global = ProjectSettings.globalize_path(zmat_file_path)
	var script_path = ProjectSettings.globalize_path("res://gc.py")
	var python_executable = "python"  # Update this if Python is not in your PATH
	
	# Prepare arguments for the Python script
	var args = PackedStringArray([script_path, "-zmat", zmat_file_global])
	print("Arguments passed to Python:", args)
	
	# Run the Python script using OS.execute()
	var output = []
	var exit_code = OS.execute(python_executable, args, output, true)  # 'true' to capture stderr
	
	# Check for errors during execution
	if exit_code != 0:
		push_error("Python script execution failed with exit code: %d" % exit_code)
		for x in output:
			push_error("Error output: %s" % (x + "\n"))
		return {}
	
	# Get the XYZ string from the output
	var xyz_string = ""
	for line in output:
		xyz_string += line + "\n"
	xyz_string = xyz_string.strip_edges()
	
	# Extract bonds from the Z-matrix
	var bonds = extract_bonds_from_zmatrix(z_matrix_string)
	
	# Clean up temporary files
	var dir = DirAccess.open("user://")
	if dir:
		dir.remove("temp_zmat.zmat")
	
	# Return the dictionary in the requested format
	return {
		"zmat": z_matrix_string,
		"xyz": xyz_string,
		"bonds": bonds
	}


#return {
#		"zmat": z_matrix_string,
#		"xyz": caertesian_string,
#		"bonds": bonds
#	} --->
func convert_coordinates_to_zmatrix(cartesian_string: String) -> Dictionary:
	var xyz_file_path = "user://temp_xyz.xyz"  # Path to store the Cartesian coordinates

	# Write the Cartesian string to a temporary XYZ file
	var xyz_file = FileAccess.open(xyz_file_path, FileAccess.WRITE)
	if xyz_file == null:
		push_error("Failed to write Cartesian coordinates to temporary file.")
		return {}
	xyz_file.store_string(cartesian_string)
	xyz_file.close()

	# Get absolute paths
	var xyz_file_global = ProjectSettings.globalize_path(xyz_file_path)
	var script_path = ProjectSettings.globalize_path("res://gc.py")
	var python_executable = "python"  # Update this if Python is not in your PATH

	# Prepare arguments for the Python script to convert XYZ to Z-matrix
	var args = PackedStringArray([script_path, "-xyz", xyz_file_global])
	print("Arguments passed to Python:", args)

	# Run the Python script using OS.execute()
	var output = []
	var exit_code = OS.execute(python_executable, args, output, true)  # 'true' to capture stderr

	# Check for errors during execution
	if exit_code != 0:
		push_error("Python script execution failed with exit code: %d" % exit_code)
		for x in output:
			push_error("Error output: %s" % (x + "\n"))
		return {}

	# Get the Z-matrix string from the output
	var zmat_string = ""
	for line in output:
		zmat_string += line + "\n"
	zmat_string = zmat_string.strip_edges()

	# Extract bonds from the Z-matrix
	var bonds = extract_bonds_from_zmatrix(zmat_string)

	# Clean up temporary files
	var dir = DirAccess.open("user://")
	if dir:
		dir.remove("temp_xyz.xyz")

	# Return the dictionary in the requested format
	return {
		"xyz": cartesian_string,
		"zmat": zmat_string,
		"bonds": bonds
	}


func import_zmat() -> Dictionary:
	content_load_error=false
	read_zmat_from_files()
	await done_reading_from_files
	print("got zmat string: ",loaded_info)
	var conversion = convert_zmatrix_to_coordinates(loaded_info)
	conversion["filename"] = last_selected_filename  # Include filename
	return conversion
	
func import_xyz() -> Dictionary:
	content_load_error=false
	var xyz_string=await read_xyz_from_files()
	var conversion=convert_coordinates_to_zmatrix(xyz_string)
	conversion["filename"]=last_selected_filename 
	return conversion
	
func export_molecule(xyz_string:String)->void:
	#converrt xyz to z matrix string
	var result = convert_coordinates_to_zmatrix(xyz_string)
	var zmat_string:String=""
	if "zmat" in result:
		zmat_string=result["zmat"]
	else:
		push_error("failed to convert xyz to z matrix format")
		return
	
	#open file dialog to let user choose save location
	if zmat_string != "":
		var file_dialog = FileDialog.new()
		file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		file_dialog.mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.filters = ["*.xyz"]
		add_child(file_dialog)
		
		file_dialog.connect("file_selected", Callable(self, "_on_export_file_selected").bind(xyz_string,zmat_string))
		file_dialog.popup_centered()
	
func _on_export_file_selected(file_path:String, xyz_string:String,zmat_string:String)->void:
	#ensure filename is clean
	var filename=file_path.get_basename()
	var directory=file_path.get_base_dir()
	
	#save xyz string to filename.xyz
	var xyz_file_path="%s/%s.xyz" % [directory,filename]
	var xyz_file= FileAccess.open(xyz_file_path,FileAccess.WRITE)
	if xyz_file == null:
		push_error("failed to create xyz file")
	else:
		xyz_file.store_string(xyz_string)
		xyz_file.close()
	
	#save zmat string to filename.zmat
	var zmat_file_path="%s/%s.zmat" %[directory,filename]
	var zmat_file=FileAccess.open(zmat_file_path, FileAccess.WRITE)
	if zmat_file==null:
		push_error("Failed to create zmat file")
	else:
		zmat_file.store_string(zmat_string)
		zmat_file.close()
	
	print("Files saved: \n%s\n%s" % [xyz_file_path, zmat_file_path])
	
#handle openxr session ready
func _on_openxr_session_begun()->void:
	# Get the reported refresh rate
	var current_refresh_rate = xr_interface.get_display_refresh_rate()
	if current_refresh_rate > 0:
		print("OpenXR: Refresh rate reported as ", str(current_refresh_rate))
	else:
		print("OpenXR: No refresh rate given by XR runtime")

	# See if we have a better refresh rate available
	var new_rate = current_refresh_rate
	var available_rates : Array = xr_interface.get_available_display_refresh_rates()
	if available_rates.size() == 0:
		print("OpenXR: Target does not support refresh rate extension")
	elif available_rates.size() == 1:
		# Only one available, so use it
		new_rate = available_rates[0]
	else:
		for rate in available_rates:
			if rate > new_rate and rate <= max_refresh_rate:
				new_rate = rate

	# Did we find a better rate?
	if current_refresh_rate != new_rate:
		print("OpenXR: Setting refresh rate to ", str(new_rate))
		xr_interface.set_display_refresh_rate(new_rate)
		current_refresh_rate = new_rate

	# Now match our physics rate
	Engine.physics_ticks_per_second = current_refresh_rate
	
	
# Handle OpenXR visible state
#this state means that our game has just started and we're about 
#to switch to the focussed state next, that the user has opened a system menu
# or the users has just took their headset off.
func _on_openxr_visible_state() -> void:
	# We always pass this state at startup,
	# but the second time we get this it means our player took off their headset
	if xr_is_focused:
		print("OpenXR lost focus")

		xr_is_focused = false

		# pause our game
		get_tree().paused = true

		emit_signal("focus_lost")
		
		
# This signal is emitted by OpenXR when our game gets focus.
# This is done at the completion of our startup, but it can also be emitted
# when the user exits a system menu, or put their headset back on.
# While handling our signal we will update the focusses state,
# unpause our node and emit our focus_gained signal.
func _on_openxr_focused_state() -> void:
	print("OpenXR gained focus")
	xr_is_focused = true

	# unpause our game
	get_tree().paused = false

	emit_signal("focus_gained")
	
	
	
# On some platforms this is only emitted when the game is being closed.
# But on other platforms this will also be emitted every time the player 
# takes off their headset.
#
# For now this method is only a place holder.
func _on_openxr_stopping() -> void:
	# Our session is being stopped.
	print("OpenXR is stopping")
	
# All we do here is emit the pose_recentered signal.
# You can connect to this signal and implement the actual recenter code.
# Often it is enough to call center_on_hmd().
func _on_openxr_pose_recentered() -> void:
	# User recentered view, we have to react to this by recentering the view.
	# This is game implementation dependent.
	emit_signal("pose_recentered")
