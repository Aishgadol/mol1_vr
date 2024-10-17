extends XRController3D

@onready var left_box=$LeftBox
@onready var c=0
#Left Controller Script

func _ready():
	pass
	
func _process(delta):
	#left_box.visible=Input.is_action_just_pressed("trigger_click")
	
	'''if Input.is_action_pressed("xr_left_trigger"):
		left_box.visible=true

		
	else:
		left_box.visible=false
	'''


func _on_button_pressed(name: String) -> void:
	print(name)
	if name=="trigger_click":
		left_box.visible=true
	
