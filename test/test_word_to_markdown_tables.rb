# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownTables < Minitest::Test
  should 'convert simple table' do
    doc = stub_doc '<table><tr><td>Foo</td><td>Bar</td></tr><tr><td>One</td><td>Two</td></tr></table>'
    doc.converter.remove_paragraphs_from_tables!
    doc.converter.semanticize_table_headers!
    
    markdown = doc.to_s
    
    assert_includes markdown, 'Foo'
    assert_includes markdown, 'Bar'
    assert_includes markdown, 'One'
    assert_includes markdown, 'Two'
  end

  should 'convert table with bold headers' do
    doc = stub_doc '<table><tr><td><strong>Header 1</strong></td><td><strong>Header 2</strong></td></tr><tr><td>Data 1</td><td>Data 2</td></tr></table>'
    doc.converter.remove_paragraphs_from_tables!
    doc.converter.semanticize_table_headers!
    
    markdown = doc.to_s
    
    assert_includes markdown, '**Header 1**'
    assert_includes markdown, '**Header 2**'
  end

  should 'handle multi-row tables' do
    doc = stub_doc '<table><tr><td>H1</td><td>H2</td></tr><tr><td>R1C1</td><td>R1C2</td></tr><tr><td>R2C1</td><td>R2C2</td></tr></table>'
    doc.converter.remove_paragraphs_from_tables!
    doc.converter.semanticize_table_headers!
    
    markdown = doc.to_s
    
    assert_includes markdown, 'R1C1'
    assert_includes markdown, 'R2C1'
  end

  should 'remove paragraphs from cells' do
    doc = stub_doc '<table><tr><td><p>Content</p></td></tr></table>'
    doc.converter.remove_paragraphs_from_tables!
    
    assert_empty doc.document.tree.css('td p')
    assert_equal 1, doc.document.tree.css('td span').length
  end

  should 'make first row headers' do
    doc = stub_doc '<table><tr><td>Header</td></tr><tr><td>Data</td></tr></table>'
    doc.converter.semanticize_table_headers!
    
    assert_equal 1, doc.document.tree.css('th').length
    assert_equal 1, doc.document.tree.css('td').length
  end

  should 'handle empty table cells' do
    doc = stub_doc '<table><tr><td></td><td>Content</td></tr></table>'
    doc.converter.semanticize_table_headers!
    
    markdown = doc.to_s
    
    assert_includes markdown, 'Content'
  end

  should 'handle nested formatting in cells' do
    doc = stub_doc '<table><tr><td><strong>Bold</strong> and <em>italic</em></td></tr></table>'
    doc.converter.remove_paragraphs_from_tables!
    doc.converter.semanticize_table_headers!
    
    markdown = doc.to_s
    
    assert_includes markdown, '**Bold**'
    assert_includes markdown, '_italic_'
  end
end
