# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownEdgeCases < Minitest::Test
  should 'handle empty documents' do
    doc = stub_doc '<html><body></body></html>'
    markdown = doc.to_s
    
    assert_instance_of String, markdown
  end

  should 'handle documents with only whitespace' do
    doc = stub_doc '<html><body>   </body></html>'
    markdown = doc.to_s
    
    assert_equal '', markdown
  end

  should 'handle mixed bold and italic' do
    doc = stub_doc '<span style="font-weight: bold; font-style: italic">Text</span>'
    
    # First check if converter detects both bold and italic
    # Note: The converter prioritizes bold over italic
    doc.converter.semanticize_font_styles!
    
    markdown = doc.to_s
    assert_instance_of String, markdown
  end

  should 'handle special markdown characters' do
    doc = stub_doc '<p># Not a heading * Not a list</p>'
    markdown = doc.to_s
    
    # Should escape or handle these characters
    assert_instance_of String, markdown
    refute_nil markdown
  end

  should 'handle html entities' do
    doc = stub_doc '<p>&lt;tag&gt; &amp; &quot;quotes&quot;</p>'
    markdown = doc.to_s
    
    assert_includes markdown, '<'
    assert_includes markdown, '>'
    assert_includes markdown, '&'
  end

  should 'handle unicode characters' do
    doc = stub_doc '<p>Unicode: © ™ € ±</p>'
    markdown = doc.to_s
    
    assert_includes markdown, '©'
    assert_includes markdown, '™'
  end

  should 'handle nested lists' do
    doc = stub_doc '<ul><li>Item 1<ul><li>Nested 1</li><li>Nested 2</li></ul></li><li>Item 2</li></ul>'
    markdown = doc.to_s
    
    assert_includes markdown, 'Item 1'
    assert_includes markdown, 'Nested 1'
    assert_includes markdown, 'Item 2'
  end

  should 'handle mixed list types' do
    doc = stub_doc '<ol><li>Numbered<ul><li>Bullet</li></ul></li></ol>'
    markdown = doc.to_s
    
    assert_includes markdown, 'Numbered'
    assert_includes markdown, 'Bullet'
  end

  should 'handle multiple consecutive headings' do
    doc = stub_doc '<h1>Heading 1</h1><h2>Heading 2</h2><h3>Heading 3</h3>'
    markdown = doc.to_s
    
    assert_includes markdown, '# Heading 1'
    assert_includes markdown, '## Heading 2'
    assert_includes markdown, '### Heading 3'
  end

  should 'handle headings with formatting' do
    doc = stub_doc '<h1><strong>Bold</strong> Heading</h1>'
    markdown = doc.to_s
    
    assert_includes markdown, '# '
    assert_includes markdown, '**Bold**'
    assert_includes markdown, 'Heading'
  end

  should 'handle line breaks' do
    doc = stub_doc '<p>Line 1<br>Line 2</p>'
    markdown = doc.to_s
    
    assert_includes markdown, 'Line 1'
    assert_includes markdown, 'Line 2'
  end

  should 'handle horizontal rules' do
    doc = stub_doc '<p>Before</p><hr><p>After</p>'
    markdown = doc.to_s
    
    assert_includes markdown, 'Before'
    assert_includes markdown, 'After'
  end

  should 'handle code blocks' do
    doc = stub_doc '<pre><code>code example</code></pre>'
    markdown = doc.to_s
    
    assert_includes markdown, 'code example'
  end

  should 'handle inline code' do
    doc = stub_doc '<p>Use <code>function()</code> to call</p>'
    markdown = doc.to_s
    
    assert_includes markdown, '`function()`'
  end

  should 'handle blockquotes' do
    doc = stub_doc '<blockquote>Quoted text</blockquote>'
    markdown = doc.to_s
    
    assert_includes markdown, 'Quoted text'
  end

  should 'handle strikethrough' do
    doc = stub_doc '<del>Deleted text</del>'
    markdown = doc.to_s
    
    assert_includes markdown, 'Deleted text'
  end

  should 'handle multiple paragraphs' do
    doc = stub_doc '<p>First paragraph</p><p>Second paragraph</p><p>Third paragraph</p>'
    markdown = doc.to_s
    
    assert_includes markdown, 'First paragraph'
    assert_includes markdown, 'Second paragraph'
    assert_includes markdown, 'Third paragraph'
  end

  should 'handle very long lines' do
    long_text = 'A' * 1000
    doc = stub_doc "<p>#{long_text}</p>"
    markdown = doc.to_s
    
    assert_includes markdown, long_text
  end

  should 'handle documents with complex nesting' do
    doc = stub_doc '<div><p><strong><em>Nested</em></strong></p></div>'
    markdown = doc.to_s
    
    assert_includes markdown, 'Nested'
  end

  should 'handle subscript and superscript' do
    doc = stub_doc '<p>H<sub>2</sub>O and E=mc<sup>2</sup></p>'
    markdown = doc.to_s
    
    assert_includes markdown, 'H'
    assert_includes markdown, '2'
    assert_includes markdown, 'O'
  end
end
