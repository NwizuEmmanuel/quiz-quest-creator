extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	list_questions()
	%QuizTitleLabel.text = QuizData.quiz_title

func list_questions():
	var file = load(QuizData.quiz_path) as Questions
	%QuizEditorItemList.clear()
	for i in file.questions:
		%QuizEditorItemList.add_item(i.text)

func show_alert_dialog(title:String, dialog_text: String):
	%QuizEditorAlertDialog.title = title
	%QuizEditorAlertDialog.dialog_text = dialog_text
	%QuizEditorAlertDialog.popup_centered()
	
func add_multiple_choice():
	if %QuestionTextTextEdit.text == "":
		show_alert_dialog("WARNING", "QUESTION IS EMPTY")
		return
	elif %Option1LineEdit.text == "":
		show_alert_dialog("WARNING", "OPTION 1 IS EMPTY")
		return
	elif %Option2LineEdit.text == "":
		show_alert_dialog("WARNING", "OPTION 2 IS EMPTY")
		return
	elif %Option3LineEdit.text == "":
		show_alert_dialog("WARNING", "OPTION 3 IS EMPTY")
		return
	elif %Option4LineEdit.text == "":
		show_alert_dialog("WARNING", "OPTION 4 IS EMPTY")
		return
	# cleaning inputs
	var option1 = %Option1LineEdit.text.strip_edges()
	var option2 = %Option2LineEdit.text.strip_edges()
	var option3 = %Option3LineEdit.text.strip_edges()
	var option4 = %Option4LineEdit.text.strip_edges()
	var options = [option1, option2, option3, option4]
	
	var question_item = QuestionItem.new()
	question_item.text = %QuestionTextTextEdit.text
	question_item.question_type = QuestionItem.QuestionType.MULTIPLE_CHOICE
	for i in options:
		question_item.options.append(i)
	question_item.points = %PointsSpinBox.value
	question_item.time_limit = %TimeLimitSpinBox.value
	question_item.correct_option = %MultipleChoiceAnswerSpinBox.value
	
	var q = load(QuizData.quiz_path)
	q.title = QuizData.quiz_title
	q.questions.append(question_item)
	
	ResourceSaver.save(q, QuizData.quiz_path)
	list_questions()

func add_identification():
	if %QuestionTextTextEdit.text == "":
		show_alert_dialog("WARNING", "QUESTION IS EMPTY")
		return
	if %IdentificationAnswerLineEdit.text == "":
		show_alert_dialog("WARNING", "IDENTIFICATION ANSWER IS EMPTY")
		return

	var item = QuestionItem.new()
	item.question_type = QuestionItem.QuestionType.IDENTIFICATION
	item.text = %QuestionTextTextEdit.text.strip_edges()
	item.correct_answer = %IdentificationAnswerLineEdit.text.to_upper().strip_edges()
	item.points = %PointsSpinBox.value
	item.time_limit = %TimeLimitSpinBox.value
	
	var q = load(QuizData.quiz_path) as Questions
	q.title = QuizData.quiz_title
	q.questions.append(item)
	ResourceSaver.save(q, QuizData.quiz_path)
	list_questions()
	

func disable_multiple_choice():
	%Option1LineEdit.editable = false
	%Option2LineEdit.editable = false
	%Option3LineEdit.editable = false
	%Option4LineEdit.editable = false
	%MultipleChoiceAnswerSpinBox.editable = false

func enable_multiple_choice():
	%Option1LineEdit.editable = true
	%Option2LineEdit.editable = true
	%Option3LineEdit.editable = true
	%Option4LineEdit.editable = true
	%MultipleChoiceAnswerSpinBox.editable = true

func enable_identification():
	%IdentificationAnswerLineEdit.editable = true

func disable_identification():
	%IdentificationAnswerLineEdit.editable = false

func clear_inputs():
	%QuestionTextTextEdit.clear()
	%Option1LineEdit.clear()
	%Option2LineEdit.clear()
	%Option3LineEdit.clear()
	%Option4LineEdit.clear()
	%IdentificationAnswerLineEdit.clear()

func _on_question_type_option_button_item_selected(index: int) -> void:
	if index == 0:
		disable_identification()
		enable_multiple_choice()
	elif index == 1:
		disable_multiple_choice()
		enable_identification()

# add/update button
func _on_add_button_pressed() -> void:
	if !%QuizEditorItemList.is_anything_selected():
		var index = %QuestionTypeOptionButton.get_selected_id()
		if index == -1:
			show_alert_dialog("WARNING", "CHOOSE QUESTION TYPE")
		elif index == 0:
			add_multiple_choice()
		elif index == 1:
			add_identification()
	elif %QuizEditorItemList.is_anything_selected():
		%UpdateQuestionConfirmationDialog.popup_centered()


func _on_delete_button_pressed() -> void:
	if %QuizEditorItemList.is_anything_selected():
		var selected_index = %QuizEditorItemList.get_selected_items()[0]

		var question = load(QuizData.quiz_path) as Questions
		question.questions.remove_at(selected_index)

		ResourceSaver.save(question, QuizData.quiz_path)
		list_questions()
	else:
		show_alert_dialog("WARNING", "SELECT A QUESTION")


func _on_quiz_editor_item_list_item_activated(index: int) -> void:
	if %QuizEditorItemList.is_anything_selected():
		clear_inputs()
		var q = load(QuizData.quiz_path) as Questions
		var selected_question = q.questions[index]
		%QuestionTextTextEdit.text = selected_question.text
		
		if selected_question.question_type == QuestionItem.QuestionType.MULTIPLE_CHOICE:
			%QuestionTypeOptionButton.select(0)
			
			%Option1LineEdit.text = selected_question.options[0]
			%Option2LineEdit.text = selected_question.options[1]
			%Option3LineEdit.text = selected_question.options[2]
			%Option4LineEdit.text = selected_question.options[3]
			%MultipleChoiceAnswerSpinBox.value = selected_question.correct_option
			enable_multiple_choice()
			disable_identification()
		elif selected_question.question_type == QuestionItem.QuestionType.IDENTIFICATION:
			%QuestionTypeOptionButton.select(1)
			%IdentificationAnswerLineEdit.text = selected_question.correct_answer
			enable_identification()
			disable_multiple_choice()
		%PointsSpinBox.value = selected_question.points
		%TimeLimitSpinBox.value = selected_question.time_limit


func _on_go_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/add_quiz.tscn")


func _on_update_question_confirmation_dialog_confirmed() -> void:
	var selected_index = %QuizEditorItemList.get_selected_items()[0]
	var selected_option = %QuestionTypeOptionButton.get_selected_id()
	var q = load(QuizData.quiz_path) as Questions
	
	var item = QuestionItem.new()
	item.text = %QuestionTextTextEdit.text.strip_edges()
	if selected_option == 0:
		item.question_type = QuestionItem.QuestionType.MULTIPLE_CHOICE
		if %Option1LineEdit.text == "" or %Option2LineEdit.text == "" or %Option3LineEdit.text == "" or %Option4LineEdit.text == "":
			show_alert_dialog("WARNING", "ONE OF THE OPTIONS IS EMPTY")
			return
		item.options.append(%Option1LineEdit.text.strip_edges())
		item.options.append(%Option2LineEdit.text.strip_edges())
		item.options.append(%Option3LineEdit.text.strip_edges())
		item.options.append(%Option4LineEdit.text.strip_edges())
		item.correct_option = %MultipleChoiceAnswerSpinBox.value
	elif selected_option == 1:
		item.question_type = QuestionItem.QuestionType.IDENTIFICATION
		if %IdentificationAnswerLineEdit.text == "":
			show_alert_dialog("WARNING", "IDENTIFICATION ANSWER IS EMPTY")
			return
		item.correct_answer = %IdentificationAnswerLineEdit.text.strip_edges().to_upper()
		
	item.points = %PointsSpinBox.value
	item.time_limit = %TimeLimitSpinBox.value
	
	q.questions[selected_index] = item
	ResourceSaver.save(q, QuizData.quiz_path)
	%QuizEditorItemList.deselect_all()


func _on_clear_button_pressed() -> void:
	clear_inputs()
	%QuizEditorItemList.deselect_all()
