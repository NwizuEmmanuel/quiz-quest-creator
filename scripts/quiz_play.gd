extends Node


var quiz_file = load(QuizData.quiz_path) as Questions
var quiz_items: Array[QuestionItem] = quiz_file.questions
var total_questions = 0
var current = 0
var score = 0
var player_max_life = 100.0
var boss_max_life = 100.0
var player_life = 0.0
var boss_life = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_questions = quiz_items.size()
	display_question()
	player_life = player_max_life
	boss_life = boss_max_life


func display_question():
	if current < total_questions:
		var q = quiz_items[current]
		var question_text = "[b]%d: %s[/b] \n\n" % [current + 1, q.text]
		var options_text = ""  
		
		if q.question_type == QuestionItem.QuestionType.MULTIPLE_CHOICE:
			options_text += "A: %s\n" %q.options[0]
			options_text += "B: %s\n" %q.options[1]
			options_text += "C: %s\n" %q.options[2]
			options_text += "D: %s\n" %q.options[3]
			%OptionsText.text = options_text
			%IdentificationAnswerBox.hide()
			%MultipleChoiceOptionsBox.show()
			%OptionsText.show()
		elif q.question_type == QuestionItem.QuestionType.IDENTIFICATION:
			%IdentificationAnswerBox.show()
			%MultipleChoiceOptionsBox.hide()
			%OptionsText.hide()
		%QuestionText.text = question_text
		%QuizTimer.start(q.time_limit)

func check_multiple_choice_answer(ans:int):
	if current < total_questions:
		var q = quiz_items[current]
		if q.correct_option == ans:
			score += 1

func next_question():
	current += 1
	display_question()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	%TimerLabel.text = "TIME: %d" % %QuizTimer.time_left
	%ScoreLabel.text = "SCORE: %d/%d" % [score,total_questions]


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
