require 'spec_helper'

describe Moodle2AA::Moodle2::Models::Section do

  it_behaves_like 'it has an attribute for', :id
  it_behaves_like 'it has an attribute for', :number
  it_behaves_like 'it has an attribute for', :name
  it_behaves_like 'it has an attribute for', :summary
  it_behaves_like 'it has an attribute for', :summary_format
  it_behaves_like 'it has an attribute for', :sequence, []
  it_behaves_like 'it has an attribute for', :visible
  it_behaves_like 'it has an attribute for', :available_from
  it_behaves_like 'it has an attribute for', :available_until
  it_behaves_like 'it has an attribute for', :release_code
  it_behaves_like 'it has an attribute for', :show_availability
  it_behaves_like 'it has an attribute for', :grouping_id
  it_behaves_like 'it has an attribute for', :position
  it_behaves_like 'it has an attribute for', :activities, []

  describe '#empty?' do
    it 'is empty if there is no summary or activites' do
      expect(subject.empty?).to be_truthy
    end

    it 'is not empty if there is a summary' do
      subject.summary = 'Summary'
      expect(subject.empty?).to be_falsey
    end

    it 'is not empty if there are activites' do
      subject.activities << :activity
      expect(subject.empty?).to be_falsey
    end
  end

  describe '#summary?' do
    it 'returns false when summary is nil' do
      expect(subject.summary?).to be_falsey
    end

    it 'returns false when summary is an empty string' do
      subject.summary = ''
      expect(subject.summary?).to be_falsey
    end

    it 'returns false when summary contains only whitespace' do
      subject.summary = '   '
      expect(subject.summary?).to be_falsey
    end

    it 'returns true when summary contains only whitespace' do
      subject.summary = 'Summary'
      expect(subject.summary?).to be_truthy
    end
  end

end