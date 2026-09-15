# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestNokogiriElement < Minitest::Test
  def parse_html(html)
    Nokogiri::HTML(html)
  end

  should 'detect font size from style' do
    doc = parse_html '<span style="font-size: 24px">Text</span>'
    element = doc.css('span').first
    
    assert_equal 24.0, element.font_size
  end

  should 'detect font size from pt units' do
    doc = parse_html '<span style="font-size: 18pt">Text</span>'
    element = doc.css('span').first
    
    assert_equal 18.0, element.font_size
  end

  should 'return default font size when no style' do
    doc = parse_html '<span>Text</span>'
    element = doc.css('span').first
    
    assert_equal 12.0, element.font_size
  end

  should 'detect bold font weight' do
    doc = parse_html '<span style="font-weight: bold">Bold</span>'
    element = doc.css('span').first
    
    assert element.bold?
  end

  should 'return false for non-bold text' do
    doc = parse_html '<span style="font-weight: normal">Normal</span>'
    element = doc.css('span').first
    
    refute element.bold?
  end

  should 'return false for bold when no style' do
    doc = parse_html '<span>Text</span>'
    element = doc.css('span').first
    
    refute element.bold?
  end

  should 'detect italic font style' do
    doc = parse_html '<span style="font-style: italic">Italic</span>'
    element = doc.css('span').first
    
    assert element.italic?
  end

  should 'return false for non-italic text' do
    doc = parse_html '<span style="font-style: normal">Normal</span>'
    element = doc.css('span').first
    
    refute element.italic?
  end

  should 'return false for italic when no style' do
    doc = parse_html '<span>Text</span>'
    element = doc.css('span').first
    
    refute element.italic?
  end

  should 'have default font size constant' do
    assert_equal 12.0, Nokogiri::XML::Element::DEFAULT_FONT_SIZE
  end
end
