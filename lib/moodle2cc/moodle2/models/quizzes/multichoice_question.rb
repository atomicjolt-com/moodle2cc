module Moodle2CC::Moodle2::Models::Quizzes
  class MultichoiceQuestion < Question
    register_question_type 'multichoice'
    attr_accessor :single, :shuffle, :correctfeedback, :incorrectfeedback, :partiallycorrectfeedback
  end
end
