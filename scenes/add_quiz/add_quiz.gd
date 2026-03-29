extends Node

@onready var file_dialog = $FileDialog
const IMPORT_DIR = "user://quizzes/" # Your target folder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	list_quiz_files()

func show_alert_dialog(title:String,dialog_text:String):
	%AddQuizAlertDialog.title = title
	%AddQuizAlertDialog.dialog_text = dialog_text
	%AddQuizAlertDialog.popup_centered()

func add_quiz():
	var path = "user://quizzes/"
	if %QuizTitleLineEdit.text == "":
		show_alert_dialog("WARNING", "TITLE IS REQUIRED")
	else:
		if FileAccess.file_exists("user://quizzes/" + %QuizTitleLineEdit.text + ".res"):
			show_alert_dialog("WARNING", "QUIZ ALREADY EXISTS")
			return 
		path += %QuizTitleLineEdit.text + ".res"
		DirAccess.make_dir_recursive_absolute("user://quizzes")
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
		QuizData.quiz_path = selected_quiz
		var selected_index = %QuizTitleItemList.get_selected_items()[0]
		QuizData.quiz_title = %QuizTitleItemList.get_item_text(selected_index)
		get_tree().change_scene_to_file("res://scenes/quiz_editor/quiz_editor.tscn")
	else:
		show_alert_dialog("WARNING", "SELECT A QUIZ")


func _on_export_button_pressed() -> void:
	%AddQuizFileDialog.popup_centered()


func _on_add_quiz_file_dialog_dir_selected(dir: String) -> void:
	# 1. Safety check: Ensure something is actually selected
	var selected_items = %QuizTitleItemList.get_selected_items()
	if selected_items.size() == 0:
		show_alert_dialog("ERROR", "NO QUIZ SELECTED")
		return
		
	var selected_index = selected_items[0]
	var quiz_title = %QuizTitleItemList.get_item_text(selected_index)
	var selected_item = %QuizTitleItemList.get_item_metadata(selected_index)
	
	# 2. Format the timestamp (Removing 'T' and ':')
	var raw_time = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_") 
	
	# 3. Use path_join to ensure there is a "/" between the folder and filename
	var file_name = quiz_title + "_" + raw_time + ".res"
	var full_path = dir.path_join(file_name)
	
	# 4. Perform the copy
	var error = DirAccess.copy_absolute(selected_item, full_path)
	
	if error == OK:
		show_alert_dialog("SUCCESS", "QUIZ EXPORTED SUCCESSFULLY")
	else:
		# Useful for debugging: prints the specific error code
		print("Export failed with error code: ", error) 
		show_alert_dialog("ERROR", "OPERATION FAILED")


func _on_go_to_hub_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_play_button_pressed() -> void:
	var selected_items = %QuizTitleItemList.get_selected_items()
	var index = selected_items[0]
	QuizData.quiz_title = %QuizTitleItemList.get_item_text(index)
	QuizData.quiz_path = %QuizTitleItemList.get_item_metadata(index)
	get_tree().change_scene_to_file("res://scenes/play_quiz/play_quiz.tscn")


func _on_import_button_pressed() -> void:
	file_dialog.popup_centered()


func _on_file_dialog_file_selected(path: String) -> void:
	# 'path' is the full path of the file the user picked
	var file_name = path.get_file() 
	var destination = IMPORT_DIR + file_name
	
	var dir = DirAccess.open("user://")
	
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
