# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownDocument < Minitest::Test
  def setup
    @doc = WordToMarkdown::Document.new fixture_path('em')
  end

  def scrub_whitespace(string)
    @doc.send(:scrub_whitespace, string)
  end

  should 'convert html-encoded spaces' do
    assert_equal 'foo bar', scrub_whitespace('foo&nbsp;bar')
  end

  should 'strip leading whitespace' do
    assert_equal "foo\n bar", scrub_whitespace(" foo\n bar")
  end

  should 'strip trailing whitespace' do
    assert_equal "foo\n bar", scrub_whitespace("foo\n bar ")
  end

  should 'strip line-trailing whitespace' do
    assert_equal "foo\n bar", scrub_whitespace("foo \n bar")
  end

  should 'strip whitespace lines' do
    assert_equal "foo\n\nbar", scrub_whitespace("foo\n  \nbar")
  end

  should 'strip quadruple line breaks' do
    assert_equal "foo\n\nbar", scrub_whitespace("foo\n\n \n\nbar")
  end

  should 'strip unicode breaks' do
    assert_equal '', scrub_whitespace("\u00A0")
  end

  should 'store the document path' do
    assert_equal fixture_path('em'), @doc.path
  end

  should 'expand relative paths' do
    doc = WordToMarkdown::Document.new 'test/fixtures/em.docx'
    assert_match %r{^/}, doc.path
  end

  should 'detect file extension' do
    assert_equal '.docx', @doc.extension
  end

  should 'have a tmpdir' do
    refute_nil @doc.tmpdir
    assert File.directory?(@doc.tmpdir)
  end

  should 'accept custom tmpdir' do
    tmpdir = Dir.mktmpdir
    doc = WordToMarkdown::Document.new fixture_path('em'), tmpdir
    
    assert_equal tmpdir, doc.tmpdir
    FileUtils.rm_rf(tmpdir)
  end

  should 'detect UTF-8 encoding' do
    @doc.stubs(:raw_html).returns('<html><meta charset="UTF-8"></html>')
    assert_equal 'UTF-8', @doc.encoding
  end

  should 'convert macintosh encoding to MacRoman' do
    @doc.stubs(:raw_html).returns('<html><meta charset="macintosh"></html>')
    assert_equal 'MacRoman', @doc.encoding
  end

  should 'default to UTF-8 when no charset specified' do
    @doc.stubs(:raw_html).returns('<html></html>')
    assert_equal 'UTF-8', @doc.encoding
  end

  should 'return nokogiri tree' do
    tree = @doc.tree
    assert_instance_of Nokogiri::HTML::Document, tree
  end

  should 'return html' do
    html = @doc.html
    assert_instance_of String, html
    refute_empty html
  end

  should 'return markdown' do
    markdown = @doc.markdown
    assert_instance_of String, markdown
  end

  should 'alias to_s to markdown' do
    assert_equal @doc.markdown, @doc.to_s
  end

  should 'remove title from tree' do
    @doc.stubs(:raw_html).returns('<html><head><title>Test</title></head><body>Content</body></html>')
    tree = @doc.tree
    
    assert_empty tree.css('title')
  end

  should 'remove linebreaks from html' do
    @doc.stubs(:raw_html).returns("<html>\n<body>\r\nContent</body></html>")
    html = @doc.send(:normalized_html)
    
    refute_includes html, "\n"
    refute_includes html, "\r"
  end

  should 'remove extra whitespace between tags' do
    @doc.stubs(:raw_html).returns('<html><body>  <p>  </p>  </body></html>')
    html = @doc.send(:normalized_html)
    
    refute_includes html, '>  <'
  end

  should 'strip extra space after bolded text' do
    text = scrub_whitespace('**bold** , text')
    assert_equal '**bold**, text', text
  end

  should 'not strip space between bold and regular text' do
    text = scrub_whitespace('**bold** text')
    assert_equal '**bold** text', text
  end
end
