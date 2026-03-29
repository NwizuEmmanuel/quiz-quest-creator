extends Resource

class_name PlayerStats

func _init() -> void:
	id = generate_unique_id()

func generate_unique_id()->String:
	var unix_time = Time.get_unix_time_from_system()
	var random_val = randi() % 10000
	return str(unix_time)+"_"+str(random_val)

@export var id: String
@export var score: int = 0
@export var quiz_title: String = ""
@export var username: String = ""
@export var quiz_frequency: int = 0
@export var defeated_boss_count: int = 0
