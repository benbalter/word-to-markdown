require 'test/unit'
require 'nokogiri-styles/node_styles'
require 'nokogiri-styles/propset'

class MockNode < Hash
  include NokogiriStyles::NodeStyles
end

class MockStyles < String
end

class TestNodeStyles < Test::Unit::TestCase
  def test_classes
    node = MockNode.new
    node['class'] = 'foo bar'
    assert_equal(%w(foo bar), node.classes)
  end

  def test_set_classes
    node = MockNode.new
    node.classes = %w(foo bar)
    assert_equal('foo bar', node['class'])
  end

  def test_styles
    node = MockNode.new
    node['style'] = 'width: 2px; height: 4px'
    assert_equal(node.styles.class, NokogiriStyles::Propset)
  end

  def test_nil_style
    node = MockNode.new
    assert_nothing_raised do
      assert_equal('', node.styles.to_s)
    end
  end

  def test_set_styles
    node = MockNode.new
    node.styles = MockStyles.new('width: 2px; height: 4px')
    assert_equal('width: 2px; height: 4px', node['style'])
  end
end
