extends Node

@onready var file_dialog: FileDialog = $FileDialog
@onready var export_dialog = $ExportDialog


# The base directory your tree will display
var save_path = "user://students_results.csv"
var INTERNAL_CSV = "user://students_results.csv"
# The headers for your CSV file
#---------------------s---------s-----------s------d-----------d------------s-------------s-------------------s--------------s-----------s-
const CSV_HEADER = "Username,Password,Quiz Title,Score,Total Questions,Defeated Boss,Schedule Date,Schedule Time From,Schedule Time To,Date\n"

func _ready():
	show_student_count()

func show_student_count():
	var total = get_student_count_from_csv(save_path)
	%StudentCountLabel.text = "Number of students: %d" % total


func get_student_count_from_csv(path: String) -> int:
	if not FileAccess.file_exists(path):
		print("No CSV found at: ", path)
		return 0

	var file = FileAccess.open(path, FileAccess.READ)
	var student_count = 0
	
	# 1. Skip the header row (ID, Username, etc.)
	if not file.eof_reached():
		file.get_line() 
	
	# 2. Loop through the remaining lines
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		
		# 3. Only count lines that actually contain data
		if line != "":
			student_count += 1
	
	file.close()
	return student_count

func _on_file_dialog_files_selected(paths: PackedStringArray):
	var csv_content = CSV_HEADER
	print(paths)
	
	for path in paths:
		# Load the custom resource (QuizResultData)
		var result = ResourceLoader.load(path) as PlayerStats
		
		if result:
			print(result.quiz_title)
			print(result.username)
			# Format the row (comma-separated)
			var row = "%s,%s,%s,%d,%d,%s,%s,%s,%s,%s\n" % [
				result.username,
				result.password,
				result.quiz_title,
				result.score,
				result.total_questions,
				result.defeated_boss,
				result.schedule_date,
				result.schedule_time_from,
				result.schedule_time_to,
				result.date_added
			]
			csv_content += row
	
	save_csv_file(csv_content)
	show_student_count()

func save_csv_file(content: String):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	if file:
		file.store_string(content)
		print("CSV created successfully at: ", ProjectSettings.globalize_path(save_path))
	else:
		print("Failed to create CSV.")


func _on_export_button_pressed() -> void:
	if FileAccess.file_exists(INTERNAL_CSV):
		export_dialog.current_file = "Student_Results_Final.csv"
		export_dialog.popup_centered()
	else:
		print("Error: No CSV file found to export. Please import results first.")
	

# 2. Triggered when the teacher chooses a location in the FileDialog
func _on_export_dialog_file_selected(path: String):
	# Copy the existing file from internal storage to the chosen path
	var error = DirAccess.copy_absolute(INTERNAL_CSV, path)
	
	if error == OK:
		print("File exported successfully to: ", path)
		# Optional: Open the folder so they can see it
		OS.shell_open(path.get_base_dir())
	else:
		print("Export failed. Error code: ", error)

func _on_go_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_get_result_button_pressed() -> void:
	file_dialog.popup_centered()
