extends Node

@onready var quiz_title_line_edit = %QuizTitleLineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	list_quiz_files()

func add_quiz():
	var path = "user://quizzes/"
	if quiz_title_line_edit.text == "":
		%TitleOverwriteDialog.title = "Title is empty"
		%TitleOverwriteDialog.popup_centered_clamped()
	else:
		if FileAccess.file_exists("user://quizzes/" + quiz_title_line_edit.text + ".res"):
			%TitleOverwriteDialog.title = "Quiz already exists"
			%TitleOverwriteDialog.popup_centered_clamped(Vector2i(230,100))
			return 
		path += quiz_title_line_edit.text + ".res"
		DirAccess.make_dir_recursive_absolute("user://quizzes")
		var q = Questions.new()
		q.title = quiz_title_line_edit.text
		ResourceSaver.save(q, path)
		quiz_title_line_edit.clear()
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
		%DeleteQuizConfirmationDialog.title = "Are you sure?"
		%DeleteQuizConfirmationDialog.popup_centered_clamped()


func _on_quiz_title_item_list_item_activated(index: int) -> void:
	var selected_quiz = %QuizTitleItemList.get_item_metadata(index)
	QuizData.quiz_path = selected_quiz
	var selected_index = %QuizTitleItemList.get_selected_items()[0]
	QuizData.quiz_title = %QuizTitleItemList.get_item_text(selected_index)
	get_tree().change_scene_to_file("res://scenes/quiz_editor.tscn")


func _on_play_button_pressed() -> void:
	var index = %QuizTitleItemList.get_selected_items()[0]
	var selected_quiz = %QuizTitleItemList.get_item_metadata(index)
	QuizData.quiz_path = selected_quiz
	var selected_index = %QuizTitleItemList.get_selected_items()[0]
	QuizData.quiz_title = %QuizTitleItemList.get_item_text(selected_index)
	get_tree().change_scene_to_file("res://scenes/quiz_play.tscn")
