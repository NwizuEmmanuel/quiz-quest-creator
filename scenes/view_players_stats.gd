extends Node

@onready var file_dialog: FileDialog = $FileDialog
@onready var export_dialog = $ExportDialog
@onready var grid_container: GridContainer = %GridContainer # Use the unique name or path


# The base directory your tree will display
var save_path = "user://students_results.csv"
var INTERNAL_CSV = "user://students_results.csv"
# The headers for your CSV file
#---------------------s---------s-------s-----------s--------d---------d-------s-------------s-------------------s--------------s------------------s--------
const CSV_HEADER = "Username,Password,Full Name,Quiz Title,Score,Total Questions,Defeated Boss,Schedule Date,Schedule Time From,Schedule Time To,DateTime Submitted\n"

func _ready():
	show_student_count()
	refresh_grid_display() # Load data into grid on startup


## Clears the GridContainer and repopulates it from the CSV file
func refresh_grid_display():
	for child in grid_container.get_children():
		child.queue_free()
	
	if not FileAccess.file_exists(save_path):
		return

	var file = FileAccess.open(save_path, FileAccess.READ)
	var row_count = 0
	
	while not file.eof_reached():
		var columns = file.get_csv_line()
		if columns.size() <= 1 and columns[0] == "":
			continue
			
		for cell_text in columns:
			# 1. Create the PanelContainer (The Background)
			var panel = PanelContainer.new()
			var style_box = StyleBoxFlat.new()
			
			# 2. Determine Color based on row type
			if row_count == 0:
				# Header Row (Dark Blue/Grey)
				style_box.bg_color = Color(0.15, 0.15, 0.2) 
			elif row_count % 2 == 0:
				# Even Rows (Slightly Lighter)
				style_box.bg_color = Color(0.2, 0.2, 0.2, 0.5)
			else:
				# Odd Rows (Transparent/Darker)
				style_box.bg_color = Color(0.1, 0.1, 0.1, 0.5)
			
			# Add some padding inside the cells
			style_box.set_content_margin_all(5)
			panel.add_theme_stylebox_override("panel", style_box)
			
			# 3. Create the Label (The Text)
			var label = Label.new()
			label.text = str(cell_text)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			
			# Header text styling
			if row_count == 0:
				label.add_theme_color_override("font_color", Color.GOLD)
			
			# 4. Assembly
			panel.add_child(label)
			grid_container.add_child(panel)
			
		row_count += 1
	
	file.close()

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
			var row = "%s,%s,%s,%s,%d,%d,%s,%s,%s,%s,%s\n" % [
				result.username,
				result.password,
				result.fullname,
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
	refresh_grid_display()
	show_student_count()

func save_csv_file(content: String):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	if file:
		file.store_string(content)
		print("CSV created successfully at: ", ProjectSettings.globalize_path(save_path))
		refresh_grid_display()
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
