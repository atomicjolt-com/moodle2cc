require 'spec_helper'

describe Moodle2AA::Moodle2::Parsers::BookParser do
  subject { Moodle2AA::Moodle2::Parsers::BookParser.new(fixture_path(File.join('moodle2', 'backup'))) }

  it "parses books" do
    book = subject.parse().first
    chapter = book.chapters.first

    expect(book.id).to eq "1"
    expect(book.module_id).to eq "6"
    expect(book.name).to eq "My First Book"
    expect(book.intro).to eq "<p>Description of my book</p>"
    expect(book.intro_format).to eq "1"
    expect(book.numbering).to eq "0"
    expect(book.custom_titles).to eq "0"
    expect(book.chapters.size).to eq 3
    expect(book.visible).to eq true

    expect(chapter.id).to eq "1"
    expect(chapter.pagenum).to eq "1"
    expect(chapter.subchapter).to be_falsey
    expect(chapter.title).to eq "Chapter 1"
    expect(chapter.content).to eq "<p>Chapter 1 content</p>"
    expect(chapter.content_format).to eq "1"
    expect(chapter.hidden).to be_falsey

  end

  it "sets subchapter to true for subchapters" do
    book = subject.parse.first
    chapter = book.chapters.detect{|c| c.id == "2"}
    expect(chapter.subchapter).to be_truthy
  end
end