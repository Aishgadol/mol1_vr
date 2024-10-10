extends Control

@onready var pauseMenu=$MainPauseMenu
@onready var anim_player=$AnimationPlayer
@onready var colorRect=$ColorRect
@onready var mainMenuVBox=$MainPauseMenu/VBoxContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
'''func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		print("haha")
		if !pauseMenu.visible:
			return'''
		

func getCurrentMenu()->String:
	if pauseMenu.visible:
		return "main"
	elif $OptionMenu.visible:
		return "option"
	return ""
func _on_back_to_pause_screen_button_pressed() -> void:
	$OptionMenu.visible=false
	$MoleculeManagementMenu.visible=false
	pauseMenu.visible=true


func _on_option_button_pressed() -> void:
	$OptionMenu.visible=true
	pauseMenu.visible=false


func _on_resume_button_pressed() -> void:
	Input.action_press("pause")
	Input.action_release("pause")

func _on_molecule_management_button_pressed()->void:
	pauseMenu.visible=false
	$MoleculeManagementMenu.visible=true
	
	
func _on_back_to_main_button_pressed() -> void:
	colorRect.visible=true
	for child in mainMenuVBox.get_children():
		if child is Button:
			child.disabled=true
			
	anim_player.play("fade_to_black")
	await anim_player.animation_finished
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")


func _on_import_zmat_pressed() -> void:
	Input.action_press("importZmat")
	Input.action_release("importZmat")
