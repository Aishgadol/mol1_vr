extends Label

var underline_margin=2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _draw():
	var text_rect = get_rect()
	var underline_y = text_rect.size.y - underline_margin
	# Start and end points for the line
	var start_point = Vector2(0, underline_y)
	var end_point=Vector2(text_rect.size.x,underline_y)
	

	# Draw the line as an underline
	draw_line(start_point, end_point, Color(1, 1, 1), 2)  # Color(1, 1, 1) is white, 2 is the line width

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
