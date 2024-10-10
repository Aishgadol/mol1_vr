extends Control

@onready var anim_player=$AnimationPlayer
@onready var menu_camera=$SubViewportContainer/SubViewport/MenuCamera
@onready var audio_player=$AudioStreamPlayer
@onready var music_on_off_button=$OptionMenu/VBoxContainer/HBoxContainer/MusicOnOffButton
@onready var vBox=$MainMenu/VBoxContainer
@onready var colorRect=$ColorRect

var musicOn=true;
var way = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("okay lets go mainmenuscript")
	audio_player.volume_db=-12
	audio_player.play() # Replace with function body.
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE) and !$MainMenu.visible:
		if !$MainMenu.visible:
			$OptionMenu.visible=false
			$MainMenu.visible=true

			


func _on_start_button_pressed() -> void:
	print("start") 
	for child in vBox.get_children():
		if child is Button:
			child.disabled=true
		
	anim_player.play("camera_trans")
	
	await anim_player.animation_finished
	#audio_player.stop()
	menu_camera.stop_camera_movement()
	get_tree().change_scene_to_file("res://Scenes/test_main_scene.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#print("done playing")


func _on_quit_button_pressed() -> void:
	colorRect.visible=true
	for child in vBox.get_children():
		if child is Button:
			child.disabled=true
	#vBox.disabled=true
			
	anim_player.play("fade_to_black")
	await anim_player.animation_finished
	get_tree().quit()

func _on_options_button_pressed() -> void:
	$MainMenu.visible=false
	$OptionMenu.visible=true


func _on_music_on_off_button_pressed() -> void:
	if musicOn:
		music_on_off_button.text="< OFF >"
		var paused_position = audio_player.get_playback_position()
		audio_player.stop()
		audio_player.set_meta("paused_position", paused_position)
		musicOn=false
	else:
		# Resume music from the paused position
		music_on_off_button.text="< ON >"
		var paused_position = audio_player.get_meta("paused_position", 0)
		audio_player.play(paused_position)
		musicOn=true
