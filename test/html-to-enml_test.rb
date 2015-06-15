require 'test/unit'

require_relative '../html-to-enml'

class TestHtmlToEnml < Test::Unit::TestCase
  def setup
    @obj = QiitaToEvernote.new

  end
  def test_to_enml_form
    assert_equal '<div></div>', @obj.to_enml_from('<div id="hoge"></div>')
    assert_equal '<a href="https://qiita.com/hoge"></a>', @obj.to_enml_from('<a href="/hoge"></a>')
    assert_equal '<a href="https://qiita.com/%EF%BC%88"></a>', @obj.to_enml_from('<a href="%EF%BC%88"></a>')
  end
end

