# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownImplicitHeadings < Minitest::Test
  def setup
    @doc = WordToMarkdown.new fixture_path('small-medium-large')
  end

  should 'translate implicit headings' do
    expected = "# Large text\n\nParagraph\n\n## Medium Text\n\nParagraph\n\n### Small text\n\nParagraph"
    validate_fixture 'small-medium-large', expected
  end

  should 'detect elements with implicit headings' do
    assert_equal 3, @doc.converter.implicit_headings.length
  end

  should "detect an element's font size" do
    assert_equal 48, @doc.converter.implicit_headings.first.font_size
  end

  should "detect a document's font sizes" do
    assert_equal [10, 20, 40, 50], @doc.converter.font_sizes
  end

  should 'guess implied heading' do
    assert_equal 'h1', @doc.converter.guess_heading(@doc.converter.implicit_headings[0])
    assert_equal 'h2', @doc.converter.guess_heading(@doc.converter.implicit_headings[1])
    assert_equal 'h3', @doc.converter.guess_heading(@doc.converter.implicit_headings[2])
  end

  should 'ignore headings below minimum size' do
    doc = stub_doc '<span style="font-size:18.0pt">Test</span>'

    assert_empty doc.converter.implicit_headings
  end

  should 'parse font size' do
    doc = stub_doc "<p style='font-size: 25px'>foo</p>"

    assert_equal 25, doc.document.tree.css('p').first.font_size
  end
end
