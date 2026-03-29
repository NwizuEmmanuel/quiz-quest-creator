extends Node

@onready var file_dialog: FileDialog = $FileDialog
@onready var export_dialog = $ExportDialog
@onready var tree = %Tree


# The base directory your tree will display
var save_path = "user://students_results.csv"
var INTERNAL_CSV = save_path
# The headers for your CSV file
const CSV_HEADER = "ID,Username,Quiz Title,Score,Quiz Frequency,Defeated Bosses\n"

func _ready():
	setup_tree_columns()
	load_csv_to_table(save_path)

func setup_tree_columns():
	tree.columns = 6
	tree.set_column_title(0, "ID")
	tree.set_column_title(1, "Username")
	tree.set_column_title(2, "Quiz Title")
	tree.set_column_title(3, "Score")
	tree.set_column_title(4, "Freq")
	tree.set_column_title(5, "Bosses")

func load_csv_to_table(path: String):
	if not FileAccess.file_exists(path):
		print("No CSV found at: ", path)
		return

	# Clear existing items
	tree.clear()
	var root = tree.create_item()
	
	var file = FileAccess.open(path, FileAccess.READ)
	
	# Skip the header row (ID, Username, etc.)
	var _header = file.get_line() 
	
	while !file.eof_reached():
		var line = file.get_line()
		if line == "": continue # Skip empty lines
		
		# Split the CSV row into an array
		var columns = line.split(",") 
		
		# Create a new row in the Tree
		var row = tree.create_item(root)
		for i in range(columns.size()):
			# Remove quotes if you used them in the export
			var clean_text = columns[i].replace('"', '')
			row.set_text(i, clean_text)

func _on_file_dialog_files_selected(paths: PackedStringArray):
	var csv_content = CSV_HEADER
	
	for path in paths:
		# Load the custom resource (QuizResultData)
		var result = load(path) as PlayerStats
		
		if result:
			# Format the row (comma-separated)
			var row = "%s,%s,%s,%d,%d,%d\n" % [
				result.id,
				result.username,
				result.quiz_title,
				result.score,
				result.quiz_frequency,
				result.defeated_boss_count
			]
			csv_content += row
	
	save_csv_file(csv_content)

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
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
