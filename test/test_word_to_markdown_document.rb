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
end
