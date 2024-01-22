module Moodle2AA::Moodle2Converter
  module QuestionConverters
    class MatchingConverter < QuestionConverter
      register_converter_type 'match'
      self.canvas_question_type = 'matching_question'

      def convert_question(moodle_question)
        canvas_question = super
        canvas_question.matches = []

        moodle_question.matches.each do |match|
          copy = match.dup
          copy[:question_text] ||= ''
          copy[:question_text].gsub(/\{(.*?)\}/, '[\1]')
          if copy[:question_text_format].to_i == 4 # markdown
            copy[:question_text] = RDiscount.new(copy[:question_text]).to_html
            copy[:question_text_format] = '1' # html
          end
          canvas_question.matches << copy
        end
        canvas_question
      end
    end
  end
end