require 'test/unit'
require 'nokogiri-styles/propset'

include NokogiriStyles

class TestPropset < Test::Unit::TestCase
  def test_getters
    propset = Propset.new('width: 2px; height: 4px; ')
    assert_equal('2px', propset['width'])
    assert_equal('4px', propset['height'])
  end

  def test_delete
    propset = Propset.new('width: 2px; height: 4px; height: 3px')
    propset.delete('height')
    propset['width'] = nil
    assert_equal(nil, propset['height'])
    assert_equal(nil, propset['width'])
  end

  def test_setters
    propset = Propset.new('width: 2px; height: 4px')
    propset['width']  = nil
    propset['height'] = '5px'
    propset['top']    = '1px'
    assert_equal(nil,   propset['width'])
    assert_equal('5px', propset['height'])
    assert_equal('1px', propset['top'])
  end

  def test_duplicate_property
    propset = Propset.new('width: 2px; height: 4px; width: 3px')
    assert_equal('4px', propset['height'])
    assert_equal('3px', propset['width'])
    propset['width'] = '2px'
    assert_equal('2px', propset['width'])
  end

  def test_to_s
    propset = Propset.new('width: 2px; height: 4px; width: 3px; ')
    propset['height'] = nil
    propset['top']    = '1px'
    propset['width']  = '5px'
    assert_equal('width: 2px; width: 5px; top: 1px', propset.to_s)
  end

  def test_invalid_property
    propset = Propset.new('width: 2px; height 4px')
    assert_equal('2px', propset['width'])
  end
end
