extends Node3D

class Set:
	var name: String
	var texture: Texture2D
	
	func _init(set_name: String, set_texture: Texture2D):
		name = set_name
		texture = set_texture

var dice: Array[PackedScene] = [
	load("res://scenes/dice/d_4.tscn"),
	load("res://scenes/dice/d_6.tscn"),
	load("res://scenes/dice/d_8.tscn"),
	load("res://scenes/dice/d_10.tscn"),
	load("res://scenes/dice/d_12.tscn"),
	load("res://scenes/dice/d_20.tscn")
]
var sets: Array[Set]

var coin: PackedScene = load("res://scenes/coin.tscn")

var active_player: String
var dice_material: StandardMaterial3D = preload("res://models/materials/dice.tres")
var active_dice: Array[Node]

var coin_material: StandardMaterial3D = preload("res://models/materials/coin.tres")

var dice_total: int = 0
var active_modifier: int = 0

var dice_pos_old: Array[Vector3] = [Vector3(0, 0, 0)]
var dice_pos_new: Array[Vector3] = [Vector3(1, 1, 1)]

var coin_pos_old: Vector3 = Vector3(0, 0, 0)
var coin_pos_new: Vector3 = Vector3(1, 1, 1)

var dice_standstill: bool = true
var coin_standstill: bool = true

var frame_count: int = 0

func _ready() -> void:
	var json: JSON = JSON.new()
	var json_read: FileAccess = FileAccess.open("user://players.json", FileAccess.READ)
	var error: Error = json.parse(json_read.get_as_text())
	if error == OK:
		var json_data = json.data
		if typeof(json_data) == TYPE_DICTIONARY:
			for dictionary in json_data.get("sets"):
				sets.append(Set.new(dictionary.get("name"), ImageTexture.create_from_image(Image.load_from_file(dictionary.get("texture")))))
		else:
			print("JSON file formatted incorrectly")
	
	coin_material.albedo_texture = ImageTexture.create_from_image(Image.load_from_file("user://textures/coin.png"))
	
	ElgatoStreamDeck.on_key_down.connect(execute_string)
	
	execute_string("switch_0")
	dice_standstill = true

func _physics_process(_delta: float) -> void:
	# Check whether dice are moving
	if !dice_standstill || !coin_standstill:
		frame_count += 1
	
	if !dice_standstill:
		if frame_count > 5:
			dice_pos_old = dice_pos_new.duplicate()
			dice_pos_new.clear()
			for die in active_dice:
				dice_pos_new.append(die.position)
			
			if !dice_pos_new.is_empty() && !dice_pos_old.is_empty():
				var validated: bool = true
				for i in dice_pos_new.size():
					validated = dice_pos_old[i].distance_to(dice_pos_new[i]) < 0.005
					if !validated: break
				
				if validated:
					dice_standstill = true
					dice_pos_old.clear()
				frame_count = 0
	
	if !coin_standstill:
		if frame_count > 5:
			var coin: RigidBody3D = $DiceView/Dice/CoinSpawn.get_child(0)
			
			if coin:
				coin_pos_old = coin_pos_new
				coin_pos_new = coin.position
				
				if coin_pos_old.distance_to(coin_pos_new) < 0.005:
					coin_standstill = true
					coin_pos_old = Vector3(0, 0, 0)
					coin.freeze = true
			
			frame_count = 0
	
	# Display player/roll information to second window
	if active_player.length() > 8:
		$InfoView/Info/Name.scale = Vector2(1 * 1 - (active_player.length() - 8) * 0.05, 1)
	else:
		$InfoView/Info/Name.scale = Vector2(1, 1)
	$InfoView/Info/Name.text = active_player
	
	$InfoView/Info/StringInstance.text = ""
	$InfoView/Info/StringInstance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$InfoView/Info/Result.text = ""
	
	if !dice_standstill:
		dice_total = 0
	var increment: int = 17
	if active_modifier > 19:
		increment += 75
	elif active_modifier > 9:
		increment += 70
	elif active_modifier:
		increment += 60
	
	for child in $InfoView/Info/Instances.get_children():
		child.free()
	
	active_dice = $DiceView/Dice/Dice.get_children()
	
	for die in active_dice:
		var dieReal : DieScript = die as DieScript
		if not dieReal:
			continue
		var value: int = dieReal.get_roll()
		
		if active_dice.size() + int(bool(active_modifier)) <= 5:
			var new_number: Label = $InfoView/Info/StringInstance.duplicate()
			var new_operator: Label = $InfoView/Info/StringInstance.duplicate()
			
			new_number.position.x -= increment
			new_operator.position.x -= increment + 35
			increment += 70
			
			new_number.text = str(value)
			$InfoView/Info/Instances.add_child(new_number)
			if (die != active_dice.back()):
				new_operator.text = "+"
				$InfoView/Info/Instances.add_child(new_operator)
		
		if !dice_standstill:
			dice_total += value
	
	if !dice_total == 0:
		if !active_dice.is_empty() && active_dice.size() + int(bool(active_modifier)) <= 5:
			$InfoView/Info/StringInstance.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			if active_modifier != 0:
				$InfoView/Info/StringInstance.text += ("+ " if active_modifier < 10 else "+") + str(active_modifier)
			$InfoView/Info/StringInstance.text += "="
		if dice_standstill:
			$InfoView/Info/Result.set("theme_override_colors/font_color", Color(1.0, 0.89, 0.663, 1.0))
		else:
			$InfoView/Info/Result.set("theme_override_colors/font_color", Color(1.0, 1.0, 1.0, 1.0))
		$InfoView/Info/Result.text = str(dice_total + active_modifier)

func execute_string(string: String) -> void:
	var command: String
	var inputs: Array[int]
	
	command = string.substr(0, string.find("_"))
	string = string.substr(string.find("_") + 1)
	
	match command:
		"roll":
			clear_box()
			dice_standstill = false
			dice_total = 0
			for i in dice.size() + 1:
				inputs.append(int(string.substr(0, string.find(","))))
				string = string.substr(string.find(",") + 1)
			roll_dice(inputs)
		"flip":
			clear_box()
			coin_standstill = false
			flip_coin()
		"switch":
			inputs.append(int(string))
			if sets.size() > inputs.front() && sets[inputs.front()].name != active_player:
				dice_material.albedo_texture = sets[inputs.front()].texture
				active_player = sets[inputs.front()].name
				clear_box()
				dice_total = 0
		"clear":
			clear_box()

func roll_dice(dice_count: Array[int]):
	dice_count.resize(dice.size() + 1)
	
	for i in dice.size():
		for j in dice_count[i]:
			var die: RigidBody3D = dice[i].instantiate()
			var path: Path3D = $DiceView/Dice/SpawnPath
			
			die.position = path.curve.sample_baked(randf_range(0, path.curve.get_baked_length()))
			die.rotation_degrees = Vector3(randf() * 360, randf() * 360, randf() * 360)
			
			var direction_to_center: Vector3 = die.position.direction_to(Vector3(0, 5, 0))
			direction_to_center = direction_to_center.rotated(Vector3(0, 1, 0), (randf() - 0.5))
			die.linear_velocity = direction_to_center * 20
			die.angular_velocity = Vector3((randf() - 0.5) * 60, 0, (randf() - 0.5) * 60)
			
			$DiceView/Dice/Dice.add_child(die)
	
	active_modifier = dice_count[dice.size()]

func flip_coin():
	var active_coin: RigidBody3D = coin.instantiate()
	
	active_coin.rotation_degrees = Vector3(randf() * 30, randf() * 360, randf() * 30)
	
	if (randi_range(0, 1) == 1):
		active_coin.rotation_degrees += Vector3(0, 0, 180)
	
	var direction_to_center: Vector3 = active_coin.position.direction_to(Vector3(-1, 2, 0))
	active_coin.linear_velocity = direction_to_center * 10
	var flip_vel: float = randf_range(20.0, 30.0)
	
	if flip_vel < 20.5:
		flip_vel = 0
	
	active_coin.angular_velocity = Vector3(0, 0, flip_vel)
	
	$DiceView/Dice/CoinSpawn.add_child(active_coin)

func clear_box():
	if !dice_standstill:
		dice_total = 0
	
	active_dice = $DiceView/Dice/Dice.get_children()
	
	for i in active_dice.size():
		active_dice[i].free()
	
	var active_coin: RigidBody3D = $DiceView/Dice/CoinSpawn.get_child(0)
	
	if active_coin:
		active_coin.free()
	
	active_dice.clear()
	dice_standstill = true
