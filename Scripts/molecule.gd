class_name Molecule
extends Node3D
'''
var id : int
var changed : bool=true
var atoms : Array = []
var bonds_list :Dictionary={}
var atom_dict : Dictionary ={}
var atoms_local_transform : Dictionary={} #might not need this

func getId()-> int:
	return self.id
	
func setId(_id:int)->void:
	self.id=_id
	
func getAtoms()->Array:
	return self.atoms
	
func setAtoms(_atoms:Array)->void:
	self.atoms=_atoms
	
func addAtom(_atom :Atom)->void:
	changed=true
	self.atoms.append(_atom)
	bonds_list[_atom.getId()]=[]
	
	
	var connections =bonds_list[atom_id]
	for bond in connections:
		print(" Atom ID: ",bond["id"], ", Bond Order: ",bond["order"])
	

func add_bond(atom1_id:int,atom2_id:int, bond_order:int):
	bonds_list[atom1_id].append({"id": atom2_id, "order": bond_order})
	bonds_list[atom2_id].append({"id": atom1_id, "order": bond_order})
	
	
'''
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("grabbable")
	add_to_group("mergeable") # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
		
