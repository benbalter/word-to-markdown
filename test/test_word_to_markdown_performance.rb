# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownPerformance < Minitest::Test
  should 'process styled elements only once' do
    doc = WordToMarkdown.new fixture_path('small-medium-large')

    # Access both methods to ensure they share the same processing
    headings = doc.converter.implicit_headings
    sizes = doc.converter.font_sizes

    # Verify that calling again returns the same cached results
    assert_same headings, doc.converter.implicit_headings
    assert_same sizes, doc.converter.font_sizes
  end

  should 'memoize list item spans selector' do
    html = '<ul><li><span>Item 1</span></li><li><span>Item 2</span></li></ul>'
    doc = stub_doc html

    # Access the private method through send
    spans1 = doc.converter.send(:list_item_spans)
    spans2 = doc.converter.send(:list_item_spans)

    # Verify that the selector is memoized
    assert_same spans1, spans2
  end

  should 'handle empty styled elements efficiently' do
    doc = stub_doc '<p>No styled elements here</p>'

    assert_empty doc.converter.implicit_headings
    assert_kind_of Array, doc.converter.font_sizes
  end
end
