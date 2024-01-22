require 'spec_helper'

describe Moodle2AA::Moodle2Converter::QuestionBankConverter do
  let(:moodle_category) {Moodle2AA::Moodle2::Models::Quizzes::QuestionCategory.new}

  it 'converts a moodle2 question category to a canvas question bank' do
    moodle_category.id = 'category id'
    moodle_category.name = 'category name'

    canvas_bank = subject.convert(moodle_category)

    expect(canvas_bank.identifier).to eq 'm223458e5bf21c734dcbf0b582c2efd2a0_question_bank'
    expect(canvas_bank.title).to eq moodle_category.name
  end

  it 'converts moodle2 questions using the correct question converters' do
    moodle_category.questions = [Moodle2AA::Moodle2::Models::Quizzes::Question.create('truefalse')]

    canvas_bank = subject.convert(moodle_category)

    expect(canvas_bank.questions.length).to eq 1
    expect(canvas_bank.questions.first.question_type).to eq 'true_false_question'
  end

  it 'converts random short answer questions into groups of short answer questions' do
    question1 = Moodle2AA::Moodle2::Models::Quizzes::Question.create('shortanswer')
    question2 = Moodle2AA::Moodle2::Models::Quizzes::Question.create('shortanswer')
    question1.id = 'blah'
    question2.id = 'bloo'
    question3 = Moodle2AA::Moodle2::Models::Quizzes::Question.create('truefalse')
    question4 = Moodle2AA::Moodle2::Models::Quizzes::Question.create('randomsamatch')
    moodle_category.questions = [question1, question2, question3, question4]

    canvas_bank = subject.convert(moodle_category)

    expect(canvas_bank.questions.count).to eq 3
    expect(canvas_bank.question_groups.count).to eq 1

    canvas_group = canvas_bank.question_groups.first
    expect(canvas_group.questions.count).to eq 2
    expect(canvas_group.questions.detect{|q| q.original_identifier == question1.id}).not_to be_nil
    expect(canvas_group.questions.detect{|q| q.original_identifier == question2.id}).not_to be_nil
  end

  it 'retains references to random questions but does not convert them' do
    question1 = Moodle2AA::Moodle2::Models::Quizzes::Question.create('random')
    question2 = Moodle2AA::Moodle2::Models::Quizzes::Question.create('random')
    question1.id = 'blah'
    question2.id = 'bloo'
    question3 = Moodle2AA::Moodle2::Models::Quizzes::Question.create('truefalse')
    question4 = Moodle2AA::Moodle2::Models::Quizzes::Question.create('truefalse')
    moodle_category.questions = [question1, question2, question3, question4]

    canvas_bank = subject.convert(moodle_category)

    expect(canvas_bank.questions.count).to eq 2
    expect(canvas_bank.random_question_references.count).to eq 2
    expect(canvas_bank.random_question_references.detect{|q| q == question1.id}).not_to be_nil
    expect(canvas_bank.random_question_references.detect{|q| q == question2.id}).not_to be_nil
  end
end