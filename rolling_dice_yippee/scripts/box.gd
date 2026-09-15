extends Node3D

class Set:
	var name: String
	var texture: Texture2D
	
	func _init(set_name: String, set_texture: Texture2D):
		name = set_name
		texture = set_texture

var die: Array[PackedScene]
var sets: Array[Set]

var active_player: String
var dice_material: StandardMaterial3D = preload("res://models/materials/dice.tres")
var active_die: Array[Node]

var dice_pos_old: Array[Vector3] = [Vector3(0, 0, 0)]
var dice_pos_new: Array[Vector3] = [Vector3(1, 1, 1)]

var dice_standstill: bool = true

var frame_count: int = 0

func _ready() -> void:
	die.append(load("res://scenes/dice/d_4.tscn"))
	die.append(load("res://scenes/dice/d_6.tscn"))
	die.append(load("res://scenes/dice/d_8.tscn"))
	die.append(load("res://scenes/dice/d_10.tscn"))
	die.append(load("res://scenes/dice/d_12.tscn"))
	die.append(load("res://scenes/dice/d_20.tscn"))
	
	var json: JSON = JSON.new()
	var json_read: FileAccess = FileAccess.open("res://players.json", FileAccess.READ)
	var error: Error = json.parse(json_read.get_as_text())
	if error == OK:
		var json_data = json.data
		if typeof(json_data) == TYPE_DICTIONARY:
			for dictionary: Dictionary in json_data.get("sets"):
				sets.append(Set.new(dictionary.get("name"), ImageTexture.create_from_image(Image.load_from_file(dictionary.get("texture")))))
		else:
			print("JSON file formatted incorrectly")
	
	ElgatoStreamDeck.on_key_down.connect(execute_string)
	
	execute_string("switch_0")
	dice_standstill = true

func _physics_process(_delta: float) -> void:
	# Check whether dice are moving
	if !dice_standstill:
		frame_count += 1
		
		if frame_count > 5:
			dice_pos_old = dice_pos_new.duplicate()
			dice_pos_new.clear()
			for dice in active_die:
				dice_pos_new.append(dice.position)
			
			if !dice_pos_new.is_empty() && !dice_pos_old.is_empty():
				var validated: bool = true
				for i in dice_pos_new.size():
					validated = dice_pos_old[i].distance_to(dice_pos_new[i]) < 0.005
					if !validated: break
				
				if validated:
					dice_standstill = true
					dice_pos_old.clear()
				frame_count = 0
	
	# Display player/roll information to second window
	if active_player.length() > 8:
		$Info/Name.scale = Vector2(1 * 1 - (active_player.length() - 8) * 0.05, 1)
	else:
		$Info/Name.scale = Vector2(1, 1)
	$Info/Name.text = active_player
	
	$Info/StringInstance.text = ""
	$Info/Result.text = ""
	var die_total: int = 0
	var increment: int = 35
	
	for child in $Info/Instances.get_children():
		child.free()
	
	for dice in active_die:
		var value: int = dice.get_roll()
		
		if active_die.size() <= 5:
			var new_number: Label = $Info/StringInstance.duplicate()
			var new_operator: Label = $Info/StringInstance.duplicate()
			
			new_number.position.x -= increment
			new_operator.position.x -= increment + 35
			increment += 70
			
			new_number.text = str(value)
			$Info/Instances.add_child(new_number)
			if (dice != active_die.back()):
				new_operator.text = "+"
				$Info/Instances.add_child(new_operator)
		
		die_total += value
	
	if !active_die.is_empty():
		if active_die.size() <= 5: $Info/StringInstance.text += "="
		if dice_standstill:
			$Info/Result.set("theme_override_colors/font_color", Color(1.0, 0.89, 0.663, 1.0))
		else:
			$Info/Result.set("theme_override_colors/font_color", Color(1.0, 1.0, 1.0, 1.0))
		$Info/Result.text = str(die_total)

func execute_string(string: String) -> void:
	var command: String
	var inputs: Array[int]
	
	command = string.substr(0, string.find("_"))
	string = string.substr(string.find("_") + 1)
	
	match command:
		"roll":
			clear_box()
			dice_standstill = false
			for i in 6:
				inputs.append(int(string.substr(0, string.find(","))))
				string = string.substr(string.find(",") + 1)
			roll_dice(inputs)
		"switch":
			inputs.append(int(string))
			if sets.size() > inputs.front() && sets[inputs.front()].name != active_player:
				dice_material.albedo_texture = sets[inputs.front()].texture
				active_player = sets[inputs.front()].name
				clear_box()
		"clear":
			clear_box()

func roll_dice(die_count: Array[int]):
	die_count.resize(die.size())
	
	for i in die.size():
		for j in die_count[i]:
			var dice: RigidBody3D = die[i].instantiate()
			var path: Path3D = $SpawnPath
			
			dice.position = path.curve.sample_baked(randf_range(0, path.curve.get_baked_length()))
			dice.rotation_degrees = Vector3(randf() * 360, randf() * 360, randf() * 360)
			
			var direction_to_center: Vector3 = dice.position.direction_to(Vector3(0, 2, 0))
			direction_to_center = direction_to_center.rotated(Vector3(0, 0, 0), (randf() - 0.5) * 10)
			dice.linear_velocity = direction_to_center * 15
			dice.angular_velocity = Vector3((randf() - 0.5) * 60, 0, (randf() - 0.5) * 60)
			
			$Die.add_child(dice)
	
	active_die = $Die.get_children()

func clear_box():
	for i in active_die.size():
		active_die[i].free()
	active_die.clear()
	dice_standstill = true

func _on_info_close_requested() -> void:
	get_tree().quit()
