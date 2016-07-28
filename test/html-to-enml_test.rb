require 'test/unit'

require_relative '../html-to-enml'

class TestHtmlToEnml < Test::Unit::TestCase
  def setup
    @obj = QiitaToEvernote.new(nil, nil)
    @header = QiitaToEvernote::ENML_HEADER

  end

  def test_to_enml_form_1
    assert_equal create_enml_body('<div></div>'), @obj.to_enml_from('<div id="hoge"></div>')
  end
  def test_to_enml_form_2
    assert_equal create_enml_body('<a href="https://qiita.com/hoge"></a>'), @obj.to_enml_from('<a href="/hoge"></a>')
  end
  def test_to_enml_form_3
    assert_equal create_enml_body('<a href="https://qiita.com/%EF%BC%88"></a>'), @obj.to_enml_from('<a href="%EF%BC%88"></a>')
  end
  def test_to_enml_form_4
    assert_equal create_enml_body('<div><code>code</code></div>'), @obj.to_enml_from('<div><pre>code</pre></div>')
  end

  private
    def create_enml_body(body)
      content = "#{QiitaToEvernote::ENML_HEADER}"
      content << "<en-note>"
      content << body
      content << "</en-note>"
    end
end

