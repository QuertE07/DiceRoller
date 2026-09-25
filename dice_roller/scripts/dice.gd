
extends RigidBody3D

class_name DieScript

var sides: Array[Node3D]

func _ready() -> void:
	sides.assign(find_children("*", "Node3D"))

func get_roll() -> int:
	var selected: int = 0
	var height: float = -20.0
	
	for face in sides:
		var face_height: float = face.global_position.y
		
		if face_height > height:
			height = face_height
			selected = (face.name).to_int()
	
	return selected
