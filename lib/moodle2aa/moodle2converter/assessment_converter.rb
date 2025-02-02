require_relative 'feedback_converter'
require_relative 'questionnaire_converter'

module Moodle2AA::Moodle2Converter
  class AssessmentConverter
    include ConverterHelper

    include FeedbackConverter
    include QuestionnaireConverter

    def convert_quiz(moodle_quiz)
      canvas_assessment = Moodle2AA::CanvasCC::Models::Assessment.new
      canvas_assessment.identifier = generate_unique_identifier_for_activity(moodle_quiz)
      canvas_assessment.title = truncate_text(moodle_quiz.name)
      canvas_assessment.description = moodle_quiz.intro
      canvas_assessment.workflow_state = workflow_state(moodle_quiz.visible)

      canvas_assessment.lock_at = Time.at(Integer(moodle_quiz.time_close)) if moodle_quiz.time_close
      canvas_assessment.unlock_at = Time.at(Integer(moodle_quiz.time_open)) if moodle_quiz.time_open

      canvas_assessment.allowed_attempts = Integer(moodle_quiz.attempts_number) if moodle_quiz.attempts_number
      canvas_assessment.allowed_attempts = -1 if canvas_assessment.allowed_attempts == 0

      canvas_assessment.scoring_policy = moodle_quiz.grade_method == 4 ? 'keep_latest' : 'keep_highest'
      canvas_assessment.access_code = moodle_quiz.password
      canvas_assessment.ip_filter = moodle_quiz.subnet
      canvas_assessment.shuffle_answers = moodle_quiz.shuffle_answers
      if moodle_quiz.time_limit && moodle_quiz.time_limit.to_i > 0
        canvas_assessment.time_limit = (moodle_quiz.time_limit.to_f / 60).ceil
      end
      canvas_assessment.quiz_type = 'practice_quiz'

      canvas_assessment.question_references = moodle_quiz.question_instances

      case moodle_quiz.preferred_behavior
      when "adaptive","interactive","adaptivenopenalty"
        report_add_warn(moodle_quiz, LEARNING, 'quiz_behaviour='+moodle_quiz.preferred_behavior)
      when "deferredcbm","immediatecbm"
        # TODO: check if canvas has CBM
        report_add_warn(moodle_quiz, LEARNING, 'quiz_behaviour='+moodle_quiz.preferred_behavior)
      when "deferredfeedback","immediatefeedback"
        # these are ok
        ;
      else
        report_add_warn(moodle_quiz, LEARNING, 'unknown quiz_hehavior='+moodle_quiz.preferred_behavior.to_s)
      end

      canvas_assessment
    end

    def convert_choice(moodle_choice)
      canvas_assessment = Moodle2AA::CanvasCC::Models::Assessment.new
      canvas_assessment.identifier = generate_unique_identifier_for_activity(moodle_choice)
      canvas_assessment.title = truncate_text(moodle_choice.name)
      canvas_assessment.description = ''
      canvas_assessment.workflow_state = workflow_state(moodle_choice.visible)

      canvas_assessment.lock_at = Time.at(Integer(moodle_choice.time_close)) if moodle_choice.time_close
      canvas_assessment.unlock_at = Time.at(Integer(moodle_choice.time_open)) if moodle_choice.time_open

      canvas_assessment.allowed_attempts = moodle_choice.completion_submit.to_i == 1 ? 1 : -1
      canvas_assessment.scoring_policy = 'keep_latest'
      canvas_assessment.quiz_type = 'survey'

      question = Moodle2AA::CanvasCC::Models::Question.create('multiple_choice_question')
      question.identifier = generate_unique_identifier_for(moodle_choice.id, '_choice_question')
      question.title = truncate_text(moodle_choice.name)
      question.material = moodle_choice.intro
      question.answers = []
      moodle_choice.options.each_with_index do |option, num|
        answer = Moodle2AA::CanvasCC::Models::Answer.new
        answer.id = generate_unique_identifier_for(moodle_choice.id, "_choice_answer#{num + 1}")
        answer.answer_text = option
        question.answers << answer
      end

      canvas_assessment.items = [question]
      canvas_assessment
    end

  end
end