require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownImplicitHeadings < Test::Unit::TestCase

  def setup
    @doc = WordToMarkdown.new fixture_path("small-medium-large")
  end

  should "translate implicit headings" do
    expected = "# Large text\n\nParagraph\n\n## Medium Text\n\nParagraph\n\n##### Small text\n\nParagraph"
    validate_fixture "small-medium-large", expected
  end

  should "detect elements with implicit headings" do
    assert_equal 3, @doc.implicit_headings.length
  end

  should "detect an element's font size" do
    assert_equal 48, @doc.implicit_headings.first.font_size
  end

  should "detect a document's font sizes" do
    assert_equal [48, 36, 24], @doc.font_sizes
  end

  should "guess implied heading" do
    assert_equal "h1", @doc.guess_heading(@doc.implicit_headings[0])
    assert_equal "h2", @doc.guess_heading(@doc.implicit_headings[1])
    assert_equal "h5", @doc.guess_heading(@doc.implicit_headings[2])
  end
end
