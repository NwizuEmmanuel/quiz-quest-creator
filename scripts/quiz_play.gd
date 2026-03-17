extends Node


var quiz_file = load(QuizData.quiz_path) as Questions
var quiz_items: Array[QuestionItem] = quiz_file.questions
var total_questions = 0
var current = 0
var score = 0
var multiple_choice_answer: int = 0
var identification_answer: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_questions = quiz_items.size()
	display_question()


func display_question():
	if current < total_questions:
		var q = quiz_items[current]
		var question_text = "[b][color=yellow]%d: %s[/color][/b] \n\n" % [current + 1, q.text]  
		
		if q.question_type == QuestionItem.QuestionType.MULTIPLE_CHOICE:
			question_text += "[font_size=20]"
			question_text += "A: %s\n" %q.options[0]
			question_text += "B: %s\n" %q.options[1]
			question_text += "C: %s\n" %q.options[2]
			question_text += "D: %s\n" %q.options[3]
			question_text += "[/font_size]"
			%IdentificationAnswerBox.hide()
			%MultipleChoiceOptionsBox.show()
		elif q.question_type == QuestionItem.QuestionType.IDENTIFICATION:
			%IdentificationAnswerBox.show()
			%MultipleChoiceOptionsBox.hide()
		%QuestionText.text = question_text

func check_multiple_choice_answer(ans:int):
	if current < total_questions:
		var q = quiz_items[current]
		if q.correct_option == ans:
			score += 1
			print("score: " + str(score))
			print("correct")
		else:
			print("wrong")

func next_question():
	current += 1
	display_question()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_option_a_pressed() -> void:
	check_multiple_choice_answer(1)
	next_question()


func _on_option_b_pressed() -> void:
	check_multiple_choice_answer(2)
	next_question()


func _on_option_c_pressed() -> void:
	check_multiple_choice_answer(3)
	next_question()


func _on_option_d_pressed() -> void:
	check_multiple_choice_answer(4)
	next_question()
