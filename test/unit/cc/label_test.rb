require 'nokogiri'
require 'minitest/autorun'
require 'test_helper'
require 'moodle2aa'

class TestUnitCCLabel < MiniTest::Test
  include TestHelper

  def setup
    convert_moodle_backup
    @mod = @backup.course.mods.find { |m| m.mod_type == "label" }
  end

  def teardown
    clean_tmp_folder
  end

  def test_it_converts_id
    @mod.id = 654
    label = Moodle2AA::CC::Label.new @mod
    assert_equal 654, label.id
  end

  def test_it_converts_title
    @mod.name = 'Section 1'
    label = Moodle2AA::CC::Label.new @mod
    assert_equal 'Section 1', label.title
  end
end
