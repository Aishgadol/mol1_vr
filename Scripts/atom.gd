class_name Atom
extends Node3D

static var id_counter:int =0

var id : int 
var numElectrons : int
var symbol:String


func _init(_symbol:String):
	symbol=_symbol
	id=id_counter
	id_counter+=1
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
