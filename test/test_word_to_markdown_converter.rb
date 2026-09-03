# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownConverter < Minitest::Test
  def setup
    @doc = WordToMarkdown::Document.new fixture_path('em')
    @converter = WordToMarkdown::Converter.new @doc
  end

  should 'initialize with a document' do
    assert_instance_of WordToMarkdown::Converter, @converter
    assert_equal @doc, @converter.document
  end

  should 'have heading depth constant' do
    assert_equal 6, WordToMarkdown::Converter::HEADING_DEPTH
  end

  should 'have heading step constant' do
    assert_equal 100 / 6, WordToMarkdown::Converter::HEADING_STEP
  end

  should 'have minimum heading size constant' do
    assert_equal 20, WordToMarkdown::Converter::MIN_HEADING_SIZE
  end

  should 'have unicode bullets constant' do
    expected = ['○', 'o', '●', "\u2022", '\\p{C}']
    assert_equal expected, WordToMarkdown::Converter::UNICODE_BULLETS
  end

  should 'convert document' do
    # Test that convert! can be called without error
    @converter.convert!
  end

  should 'semanticize bold font styles' do
    doc = stub_doc '<span style="font-weight: bold">Bold text</span>'
    doc.converter.semanticize_font_styles!
    
    assert_equal 'strong', doc.document.tree.css('strong').first.name
    assert_includes doc.to_s, '**Bold text**'
  end

  should 'semanticize italic font styles' do
    doc = stub_doc '<span style="font-style: italic">Italic text</span>'
    doc.converter.semanticize_font_styles!
    
    assert_equal 'em', doc.document.tree.css('em').first.name
    assert_includes doc.to_s, '_Italic text_'
  end

  should 'remove paragraphs from table cells' do
    doc = stub_doc '<table><tr><td><p>Cell content</p></td></tr></table>'
    doc.converter.remove_paragraphs_from_tables!
    
    assert_empty doc.document.tree.css('td p')
    assert_equal 1, doc.document.tree.css('td span').length
  end

  should 'remove paragraphs from list items' do
    doc = stub_doc '<ul><li><p>List item</p></li></ul>'
    doc.converter.remove_paragraphs_from_list_items!
    
    assert_empty doc.document.tree.css('li p')
    assert_equal 1, doc.document.tree.css('li span').length
  end

  should 'semanticize table headers' do
    doc = stub_doc '<table><tr><td>Header 1</td><td>Header 2</td></tr><tr><td>Cell 1</td><td>Cell 2</td></tr></table>'
    doc.converter.semanticize_table_headers!
    
    assert_equal 2, doc.document.tree.css('th').length
    assert_equal 2, doc.document.tree.css('td').length
  end

  should 'remove whitespace from list items' do
    doc = stub_doc '<ul><li><span>  Item with spaces  </span></li></ul>'
    doc.converter.remove_whitespace_from_list_items!
    
    refute_includes doc.document.tree.css('li span').first.inner_html, '  '
  end

  should 'guess heading for large font size' do
    doc = WordToMarkdown.new fixture_path('small-medium-large')
    element = doc.converter.implicit_headings[0]
    
    assert_equal 'h1', doc.converter.guess_heading(element)
  end

  should 'return nil for elements without large font size' do
    doc = stub_doc '<span>Regular text</span>'
    element = doc.document.tree.css('span').first
    
    # Elements without explicit font-size get DEFAULT_FONT_SIZE (12.0)
    # which is below MIN_HEADING_SIZE (20), so should return nil
    assert_nil doc.converter.guess_heading(element)
  end

  should 'calculate minimum heading sizes' do
    doc = WordToMarkdown.new fixture_path('small-medium-large')
    
    # h1 should have highest threshold
    h1_size = doc.converter.h(1)
    h2_size = doc.converter.h(2)
    
    assert h1_size > h2_size
  end

  should 'collect font sizes from document' do
    doc = WordToMarkdown.new fixture_path('small-medium-large')
    sizes = doc.converter.font_sizes
    
    assert_instance_of Array, sizes
    refute_empty sizes
    assert_equal sizes.sort, sizes # Should be sorted
  end

  should 'collect implicit headings' do
    doc = WordToMarkdown.new fixture_path('small-medium-large')
    headings = doc.converter.implicit_headings
    
    assert_instance_of Array, headings
    refute_empty headings
  end

  should 'filter out small font sizes from implicit headings' do
    doc = stub_doc '<span style="font-size:10pt">Small</span><span style="font-size:30pt">Large</span>'
    
    # Only the large text should be an implicit heading
    assert_equal 1, doc.converter.implicit_headings.length
    assert_equal 30, doc.converter.implicit_headings.first.font_size
  end
end
