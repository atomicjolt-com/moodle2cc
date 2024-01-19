require 'spec_helper'

describe Moodle2AA::Moodle2::Parsers::FeedbackParser do
  subject { Moodle2AA::Moodle2::Parsers::FeedbackParser.new(fixture_path(File.join('moodle2', 'backup'))) }

  it 'should parse a feedback activity' do
    feedbacks = subject.parse
    expect(feedbacks.count).to eq 2
    feedback = feedbacks.detect{|f| f.id == '7'}

    expect(feedback.module_id).to eq '58588'
    expect(feedback.name).to eq 'feedback name'
    expect(feedback.intro).to eq '<p>feedback description</p>'
    expect(feedback.intro_format).to eq '1'
    expect(feedback.time_close).to eq '0'
    expect(feedback.time_open).to eq '0'
    expect(feedback.time_modified).to eq '1397566320'
    expect(feedback.multiple_submit).to eq false

    expect(feedback.items.count).to eq 9
    item = feedback.items.last
    expect(item.id).to eq '131'
    expect(item.name).to eq 'short text question'
    expect(item.label).to eq 'shorttextlabel'
    expect(item.position).to eq '9'
    expect(item.type).to eq 'textfield'
    expect(item.presentation).to eq '30|5'

    feedback2 = feedbacks.detect{|f| f.id == '8'}
    expect(feedback2.multiple_submit).to eq true
  end

end