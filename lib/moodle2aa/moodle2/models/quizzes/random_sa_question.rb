module Moodle2AA::Moodle2::Models::Quizzes
  class RandomSAQuestion < Question
    register_question_type 'randomsamatch'
    attr_accessor :choose
  end
end