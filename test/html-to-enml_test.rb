require 'test/unit'

require_relative '../html-to-enml'

class TestHtmlToEnml < Test::Unit::TestCase
  def setup
    @obj = QiitaToEvernote.new

  end
  def test_to_enml_form
    assert_equal '<div></div>', @obj.to_enml_from('<div id="hoge"></div>')
  end
end

