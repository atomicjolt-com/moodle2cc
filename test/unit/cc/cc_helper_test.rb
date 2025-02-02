require 'minitest/autorun'
require 'test_helper'
require 'moodle2aa'

class TestUnitCCCCHelper < MiniTest::Test
  include TestHelper

  def test_it_creates_valid_file_names
    assert_equal 'psy101-isnt-this-a-cool-course', Moodle2AA::CC::CCHelper.file_slug("PSY101 Isn't this a cool course?")
  end

  def test_that_file_names_dont_end_with_a_period
    assert_equal 'some-content', Moodle2AA::CC::CCHelper.file_slug('Some Content...')
  end

  def test_is_converts_file_path_tokens
    assert_equal '$IMS_CC_FILEBASE$/folder/stuff.jpg', Moodle2AA::CC::CCHelper.convert_file_path_tokens('$@FILEPHP@$$@SLASH@$folder$@SLASH@$stuff.jpg')
  end
end
