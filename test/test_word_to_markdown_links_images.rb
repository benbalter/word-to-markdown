# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownLinks < Minitest::Test
  should 'convert hyperlinks' do
    doc = stub_doc '<a href="https://example.com">Link text</a>'
    markdown = doc.to_s
    
    assert_includes markdown, '[Link text](https://example.com)'
  end

  should 'handle links without text' do
    doc = stub_doc '<a href="https://example.com"></a>'
    markdown = doc.to_s
    
    assert_includes markdown, 'https://example.com'
  end

  should 'handle links with nested formatting' do
    doc = stub_doc '<a href="https://example.com"><strong>Bold link</strong></a>'
    markdown = doc.to_s
    
    assert_includes markdown, '**Bold link**'
    assert_includes markdown, 'https://example.com'
  end

  should 'preserve multiple links' do
    doc = stub_doc '<p><a href="https://one.com">First</a> <a href="https://two.com">Second</a></p>'
    markdown = doc.to_s
    
    assert_includes markdown, '[First](https://one.com)'
    assert_includes markdown, '[Second](https://two.com)'
  end

  should 'handle links in lists' do
    doc = stub_doc '<ul><li><a href="https://example.com">List link</a></li></ul>'
    markdown = doc.to_s
    
    assert_includes markdown, '[List link](https://example.com)'
  end

  should 'handle relative URLs' do
    doc = stub_doc '<a href="/path/to/page">Relative link</a>'
    markdown = doc.to_s
    
    assert_includes markdown, '[Relative link](/path/to/page)'
  end

  should 'handle anchor links' do
    doc = stub_doc '<a href="#section">Anchor</a>'
    markdown = doc.to_s
    
    assert_includes markdown, '[Anchor](#section)'
  end

  should 'handle email links' do
    doc = stub_doc '<a href="mailto:test@example.com">Email</a>'
    markdown = doc.to_s
    
    assert_includes markdown, 'test@example.com'
  end
end

class TestWordToMarkdownImages < Minitest::Test
  should 'convert images' do
    doc = stub_doc '<img src="image.png" alt="Alt text">'
    markdown = doc.to_s
    
    assert_includes markdown, '![Alt text](image.png)'
  end

  should 'handle images without alt text' do
    doc = stub_doc '<img src="image.png">'
    markdown = doc.to_s
    
    assert_includes markdown, 'image.png'
  end

  should 'handle images with absolute URLs' do
    doc = stub_doc '<img src="https://example.com/image.png" alt="Remote image">'
    markdown = doc.to_s
    
    assert_includes markdown, '![Remote image](https://example.com/image.png)'
  end

  should 'handle images in paragraphs' do
    doc = stub_doc '<p>Text before <img src="img.png" alt="Image"> text after</p>'
    markdown = doc.to_s
    
    assert_includes markdown, '![Image](img.png)'
  end

  should 'handle linked images' do
    doc = stub_doc '<a href="https://example.com"><img src="image.png" alt="Linked"></a>'
    markdown = doc.to_s
    
    # Should contain both link and image
    assert_includes markdown, 'image.png'
    assert_includes markdown, 'example.com'
  end
end
