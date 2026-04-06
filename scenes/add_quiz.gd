extends Node

@onready var file_dialog = $FileDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("user://quizzes/")
	list_quiz_files()

func show_alert_dialog(title:String,dialog_text:String):
	%AddQuizAlertDialog.title = title
	%AddQuizAlertDialog.dialog_text = dialog_text
	%AddQuizAlertDialog.popup_centered()

func add_quiz():
	if %QuizTitleLineEdit.text == "":
		show_alert_dialog("WARNING", "TITLE IS REQUIRED")
	else:
		if FileAccess.file_exists("user://quizzes/" + %QuizTitleLineEdit.text + ".res"):
			show_alert_dialog("WARNING", "QUIZ ALREADY EXISTS")
			return 
		var path = "user://quizzes/" + %QuizTitleLineEdit.text + ".res"
		var q = Questions.new()
		q.title = %QuizTitleLineEdit.text
		ResourceSaver.save(q, path)
		%QuizTitleLineEdit.clear()
		list_quiz_files()

func list_quiz_files():
	%QuizTitleItemList.clear()
	var dir = DirAccess.open("user://quizzes")
	var index = 0
	if dir:
		for f in dir.get_files():
			if f.ends_with(".res"):
				%QuizTitleItemList.add_item(f.get_basename())
				%QuizTitleItemList.set_item_metadata(index, "user://quizzes/" + f) 
				index += 1

func delete_quiz():
	var item_list = %QuizTitleItemList
	var selected_index = item_list.get_selected_items()[0]
	var path = item_list.get_item_metadata(selected_index)
	DirAccess.remove_absolute(path)
	list_quiz_files()


func _on_create_button_pressed() -> void:
	add_quiz()


func _on_delete_quiz_confirmation_dialog_confirmed() -> void:
	delete_quiz()


func _on_remove_button_pressed() -> void:
	var item_list = %QuizTitleItemList
	if item_list.is_anything_selected():
		var index = item_list.get_selected_items()[0]
		var item_text = item_list.get_item_text(index)
		%DeleteQuizConfirmationDialog.title = "DELETE"
		%DeleteQuizConfirmationDialog.dialog_text = "DO YOU WANT TO DELETE %s?" % item_text
		%DeleteQuizConfirmationDialog.popup_centered_clamped()


func _on_edit_button_pressed() -> void:
	if %QuizTitleItemList.is_anything_selected():
		var index = %QuizTitleItemList.get_selected_items()[0]
		var selected_quiz = %QuizTitleItemList.get_item_metadata(index)
		Global.quiz_path = selected_quiz
		var selected_index = %QuizTitleItemList.get_selected_items()[0]
		Global.quiz_title = %QuizTitleItemList.get_item_text(selected_index)
		get_tree().change_scene_to_file("res://scenes/quiz_editor.tscn")
	else:
		show_alert_dialog("WARNING", "SELECT A QUIZ")


func _on_export_button_pressed() -> void:
	%AddQuizFileDialog.popup_centered()


func _on_add_quiz_file_dialog_dir_selected(dir: String) -> void:
	if Global.schedule_time_from == "" or Global.schedule_time_to == "":
		show_alert_dialog("ERROR", "Schedule time not found.")
		return
	# 1. Safety check: Ensure something is actually selected
	var selected_items = %QuizTitleItemList.get_selected_items()
	if selected_items.size() == 0:
		show_alert_dialog("ERROR", "NO QUIZ SELECTED")
		return
		
	var selected_index = selected_items[0]
	var quiz_title = %QuizTitleItemList.get_item_text(selected_index)
	var selected_item = %QuizTitleItemList.get_item_metadata(selected_index)
	
	# 3. Use path_join to ensure there is a "/" between the folder and filename
	var file_name = quiz_title + ".res"
	var full_path = dir.path_join(file_name)
	
	schedule_time(selected_item)
	add_participants(selected_item)
	# 4. Perform the copy
	var error = DirAccess.copy_absolute(selected_item, full_path)
	
	if error == OK:
		show_alert_dialog("SUCCESS", "QUIZ EXPORTED SUCCESSFULLY")
	else:
		# Useful for debugging: prints the specific error code
		print("Export failed with error code: ", error) 
		show_alert_dialog("ERROR", "OPERATION FAILED")


func _on_go_to_hub_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_play_button_pressed() -> void:
	var selected_items = %QuizTitleItemList.get_selected_items()
	var index = selected_items[0]
	Global.quiz_title = %QuizTitleItemList.get_item_text(index)
	Global.quiz_path = %QuizTitleItemList.get_item_metadata(index)
	get_tree().change_scene_to_file("res://scenes/play_quiz.tscn")


func _on_import_button_pressed() -> void:
	file_dialog.popup_centered()


func _on_file_dialog_file_selected(path: String) -> void:
	# 'path' is the full path of the file the user picked
	var file_name = path.get_file() 
	var destination = "user://quizzes/" + file_name
	
	var dir = DirAccess.open("user://quizzes/")
	
	if dir.file_exists(destination):
		print("File already exists! Overwriting...")
	
	# Use copy_absolute for files coming from outside the project
	var error = DirAccess.copy_absolute(path, destination)
	
	if error == OK:
		print("Import Successful: ", destination)
		# Optional: Refresh your UI list here
	else:
		print("Error importing file. Code: ", error)
	list_quiz_files()

func schedule_time(quiz_path: String):
	var questions = load(quiz_path) as Questions
	questions.schedule_time_from = Global.schedule_time_from
	questions.schedule_time_to = Global.schedule_time_to
	questions.schedule_date = Global.schedule_date
	ResourceSaver.save(questions, quiz_path)

func add_participants(quiz_path: String):
	var path = "user://all_students_data.res"
	var questions = load(quiz_path) as Questions
	var all_students = load(path) as AllStudents
	var students = all_students.all_students
	questions.participants = students
	ResourceSaver.save(questions, quiz_path)


func _on_schedule_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/schedule_time.tscn")
