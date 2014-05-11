require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdown < Test::Unit::TestCase

  should "properly parse italic text" do
    validate_fixture "em", "This word is _italic_."
  end

  should "properly parse bold text" do
    validate_fixture "strong", "This word is **bold**."
  end

  should "properly parse explicit h1's" do
    validate_fixture "h1", "# Heading 1\n\nParagraph text"
  end

  should "properly parse explicit h2's" do
    validate_fixture "h2", "## Heading 2\n\nParagraph text"
  end

  should "properly parse paragraphs" do
    validate_fixture "p", "This is paragraph text."
  end

  should "properly parse multiple-headings" do
    expected = "# H1\n\nParagraph\n\n## H2\n\nParagraph\n\n### H3\n\nParagraph"
    validate_fixture "multiple-headings", expected
  end

  should "parse tables" do
    validate_fixture "table", "| **Foo** | **Bar** |\n| One | Two |\n| Three | Four |"
  end

  should "accept string input" do
    assert_equal "# Heading", stub_doc("<h1>Heading</h1>").to_s
  end

  should "not mangle encoding" do
    doc = stub_doc "<span>…</span>"
    assert_equal "…", doc.to_s
  end

  should "straighten double curly quotes" do
    doc = stub_doc "<span>“”</span>"
    assert_equal '""', doc.to_s
  end

  should "straighten single curly quotes" do
    doc = stub_doc "<span>‘’</span>"
    assert_equal "''", doc.to_s
  end
end
