# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

# WordToMarkdown::Converter.percentile replaces the descriptive_statistics gem.
# Expected values below were produced by descriptive_statistics 2.5.1's
# `percentile` so heading detection stays byte-for-byte identical. Exact
# equality is intentional, so assert_in_delta would defeat the point.
class TestWordToMarkdownPercentile < Minitest::Test
  EXPECTED = {
    [10, 20, 40, 50] => { 0 => 10.0, 16 => 14.8, 32 => 19.6, 48 => 28.799999999999997, 64 => 38.4, 100 => 50.0 },
    [10, 20, 30] => { 0 => 10.0, 16 => 13.2, 32 => 16.4, 48 => 19.6, 64 => 22.8, 100 => 30.0 },
    [12, 24] => { 0 => 12.0, 16 => 13.92, 32 => 15.84, 48 => 17.759999999999998, 64 => 19.68, 100 => 24.0 }
  }.freeze

  EXPECTED.each do |values, percentiles|
    percentiles.each do |pct, expected|
      should "match descriptive_statistics for the #{pct}th percentile of #{values.inspect}" do
        assert_equal expected, WordToMarkdown::Converter.percentile(values, pct)
      end
    end
  end

  should 'sort unsorted input' do
    # rubocop:disable-next Minitest/AssertInDelta
    assert_equal 28.799999999999997, WordToMarkdown::Converter.percentile([50, 10, 40, 20], 48)
  end

  should 'return the only value as a float for a single-element collection' do
    # rubocop:disable-next Minitest/AssertInDelta
    assert_equal 7.0, WordToMarkdown::Converter.percentile([7], 32)
  end

  should 'return nil for an empty collection' do
    assert_nil WordToMarkdown::Converter.percentile([], 50)
  end

  should 'not mutate its input' do
    values = [3, 1, 2]
    WordToMarkdown::Converter.percentile(values, 50)

    assert_equal [3, 1, 2], values
  end
end
