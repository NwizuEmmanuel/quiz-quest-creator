extends Node

@onready var question_text_text_edit = %QuestionTextTextEdit
@onready var option_1_line_edit = %Option1LineEdit
@onready var option_2_line_edit = %Option2LineEdit
@onready var option_3_line_edit = %Option3LineEdit
@onready var option_4_line_edit = %Option4LineEdit
@onready var identification_answer_line_edit = %IdentificationAnswerLineEdit
@onready var multiple_choice_answer_spin_box = %MultipleChoiceAnswerSpinBox
@onready var points_spin_box = %PointsSpinBox
@onready var duration_spin_box = %DurationSpinBox
@onready var question_type_option_button = %QuestionTypeOptionButton
@onready var quiz_editor_item_list = %QuizEditorItemList
@onready var quiz_editor_dialog = %QuizEditorDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	list_questions()

func list_questions():
	var file = load(QuizData.quiz_path) as Questions
	quiz_editor_item_list.clear()
	for i in file.questions:
		quiz_editor_item_list.add_item(i.text) 

	
func add_multiple_choice():
	if question_text_text_edit.text == "":
		quiz_editor_dialog.title = "question is required"
		quiz_editor_dialog.popup_centered(Vector2i(200,100))
		return
	elif option_1_line_edit.text == "":
		quiz_editor_dialog.title = "option 1 is required"
		quiz_editor_dialog.popup_centered(Vector2i(200,100))
		return
	elif option_2_line_edit.text == "":
		quiz_editor_dialog.title = "option 2 is required"
		quiz_editor_dialog.popup_centered(Vector2i(200,100))
		return
	elif option_3_line_edit.text == "":
		quiz_editor_dialog.title = "option 3 is required"
		quiz_editor_dialog.popup_centered(Vector2i(200,100))
		return
	elif option_4_line_edit.text == "":
		quiz_editor_dialog.title = "option 4 is required"
		quiz_editor_dialog.popup_centered(Vector2i(200,100))
		return
	# cleaning inputs
	var option1 = option_1_line_edit.text.strip_edges()
	var option2 = option_2_line_edit.text.strip_edges()
	var option3 = option_3_line_edit.text.strip_edges()
	var option4 = option_4_line_edit.text.strip_edges()
	var options = [option1, option2, option3, option4]
	
	var question_item = QuestionItem.new()
	question_item.text = question_text_text_edit.text
	question_item.question_type = QuestionItem.QuestionType.MULTIPLE_CHOICE
	for i in options:
		question_item.options.append(i)
	question_item.points = points_spin_box.value
	question_item.duration = duration_spin_box.value
	question_item.correct_option = multiple_choice_answer_spin_box.value
	
	var q = load(QuizData.quiz_path)
	q.title = QuizData.quiz_title
	q.questions.append(question_item)
	
	ResourceSaver.save(q, QuizData.quiz_path)
	list_questions()

func add_identification():
	if question_text_text_edit.text == "":
		quiz_editor_dialog.title = "question is required"
		quiz_editor_dialog.popup_centered(Vector2i(200,100))
		return
	if identification_answer_line_edit.text == "":
		quiz_editor_dialog.title = "identification answer is required"
		quiz_editor_dialog.popup_centered(Vector2i(400,100))
		return

	var item = QuestionItem.new()
	item.question_type = QuestionItem.QuestionType.IDENTIFICATION
	item.text = question_text_text_edit.text.strip_edges()
	item.correct_answer = identification_answer_line_edit.text.to_upper().strip_edges()
	item.points = points_spin_box.value
	item.duration = duration_spin_box.value
	
	var q = load(QuizData.quiz_path) as Questions
	q.title = QuizData.quiz_title
	q.questions.append(item)
	ResourceSaver.save(q, QuizData.quiz_path)
	list_questions()
	

func disable_multiple_choice():
	option_1_line_edit.editable = false
	option_2_line_edit.editable = false
	option_3_line_edit.editable = false
	option_4_line_edit.editable = false
	multiple_choice_answer_spin_box.editable = false

func enable_multiple_choice():
	option_1_line_edit.editable = true
	option_2_line_edit.editable = true
	option_3_line_edit.editable = true
	option_4_line_edit.editable = true
	multiple_choice_answer_spin_box.editable = true

func enable_identification():
	identification_answer_line_edit.editable = true

func disable_identification():
	identification_answer_line_edit.editable = false

func clear_inputs():
	question_text_text_edit.clear()
	option_1_line_edit.clear()
	option_2_line_edit.clear()
	option_3_line_edit.clear()
	option_4_line_edit.clear()
	multiple_choice_answer_spin_box.value = 1
	identification_answer_line_edit.clear()
	points_spin_box.value = 1
	duration_spin_box.value = 5

func _on_question_type_option_button_item_selected(index: int) -> void:
	if index == 0:
		disable_identification()
		enable_multiple_choice()
	elif index == 1:
		disable_multiple_choice()
		enable_identification()

# add/update button
func _on_add_button_pressed() -> void:
	if !quiz_editor_item_list.is_anything_selected():
		var index = question_type_option_button.get_selected_id()
		if index == -1:
			quiz_editor_dialog.title = "choose question type"
			quiz_editor_dialog.popup_centered(Vector2i(250,100))
		elif index == 0:
			add_multiple_choice()
		elif index == 1:
			add_identification()
	elif quiz_editor_item_list.is_anything_selected():
		var selected_index = quiz_editor_item_list.get_selected_items()[0]
		var q = load(QuizData.quiz_path) as Questions
		
		
		var item = QuestionItem.new()
		item.text = question_text_text_edit.text.strip_edges()
		if q.questions[selected_index].question_type == QuestionItem.QuestionType.MULTIPLE_CHOICE:
			item.options.append(option_1_line_edit.text.strip_edges())
			item.options.append(option_2_line_edit.text.strip_edges())
			item.options.append(option_3_line_edit.text.strip_edges())
			item.options.append(option_4_line_edit.text.strip_edges())
			item.correct_option = multiple_choice_answer_spin_box.value
		elif q.questions[selected_index].question_type == QuestionItem.QuestionType.IDENTIFICATION:
			item.correct_answer = identification_answer_line_edit.text.strip_edges().to_upper()
			
		item.points = points_spin_box.value
		item.duration = duration_spin_box.value
		
		q.questions[selected_index] = item
		ResourceSaver.save(q, QuizData.quiz_path)
		quiz_editor_item_list.deselect_all()
	clear_inputs()


func _on_delete_button_pressed() -> void:
	if quiz_editor_item_list.is_anything_selected():
		var selected_index = quiz_editor_item_list.get_selected_items()[0]

		var question = load(QuizData.quiz_path) as Questions
		question.questions.remove_at(selected_index)

		ResourceSaver.save(question, QuizData.quiz_path)
		list_questions()
	else:
		quiz_editor_dialog.title = "select a question"
		quiz_editor_dialog.popup_centered(Vector2i(200,100))


func _on_quiz_editor_item_list_item_activated(index: int) -> void:
	if quiz_editor_item_list.is_anything_selected():
		clear_inputs()
		var q = load(QuizData.quiz_path) as Questions
		var selected_question = q.questions[index]
		question_text_text_edit.text = selected_question.text
		
		if selected_question.question_type == QuestionItem.QuestionType.MULTIPLE_CHOICE:
			question_type_option_button.select(0)
			
			option_1_line_edit.text = selected_question.options[0]
			option_2_line_edit.text = selected_question.options[1]
			option_3_line_edit.text = selected_question.options[2]
			option_4_line_edit.text = selected_question.options[3]
			multiple_choice_answer_spin_box.value = selected_question.correct_option
			enable_multiple_choice()
			disable_identification()
		elif selected_question.question_type == QuestionItem.QuestionType.IDENTIFICATION:
			question_type_option_button.select(1)
			identification_answer_line_edit.text = selected_question.correct_answer
			enable_identification()
			disable_multiple_choice()
		points_spin_box.value = selected_question.points
		duration_spin_box.value = selected_question.duration
