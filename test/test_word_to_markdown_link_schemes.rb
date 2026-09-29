# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownLinkSchemes < Minitest::Test
  should 'unwrap javascript: hyperlinks in Word documents' do
    validate_fixture 'javascript-link', "word-to-markdown\n\n- [word-to-markdown](https://github.com/benbalter/word-to-markdown)"
  end

  def convert(html)
    stub_doc(html).to_s
  end

  {
    'javascript' => 'javascript:alert(1)',
    'mixed-case javascript' => 'JaVaScRiPt:alert(1)',
    'control-character-prefixed javascript' => "\x01javascript:alert(1)",
    'whitespace-prefixed javascript' => " \tjavascript:alert(1)",
    'entity-encoded javascript' => '&#x6A;avascript:alert(1)',
    'vbscript' => 'vbscript:msgbox(1)',
    'data' => 'data:text/html,<script>alert(1)</script>'
  }.each do |name, href|
    should "unwrap #{name} links to plain text" do
      html = "<p>before <a href=\"#{href.gsub('<', '&lt;').gsub('>', '&gt;')}\">click</a> after</p>"

      assert_equal 'before click after', convert(html)
    end
  end

  {
    'https' => 'https://example.com/',
    'http' => 'http://example.com/',
    'mailto' => 'mailto:user@example.com',
    'fragment' => '#section',
    'relative' => 'page.html'
  }.each do |name, href|
    should "keep #{name} links" do
      assert_equal "[click](#{href})", convert("<p><a href=\"#{href}\">click</a></p>")
    end
  end

  ["java\tscript:alert(1)", "java\nscript:alert(1)", "\x00javascript:alert(1)", "javascript:alert(1)\x01"].each do |href|
    should "reject #{href.inspect} as a link target" do
      refute WordToMarkdown::UrlScrubber.safe_link?(href)
    end
  end

  should 'keep anchors without an href' do
    assert_equal 'text', convert('<p><a name="bookmark">text</a></p>')
  end

  %w[javascript:alert(1) vbscript:msgbox(1) data:text/html,x].each do |src|
    should "remove images with a #{src.split(':').first} source" do
      assert_equal 'text', convert("<p>text<img src=\"#{src}\"></p>")
    end
  end

  ['https://example.com/a.png', 'image.png', 'data:image/png;base64,iVBORw0KGgo='].each do |src|
    should "keep images with source #{src}" do
      assert_equal "text ![](#{src})", convert("<p>text<img src=\"#{src}\"></p>")
    end
  end
end
