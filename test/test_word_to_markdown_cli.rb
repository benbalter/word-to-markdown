# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownCli < Minitest::Test
  should 'return usage information' do
    output, status = Open3.capture2e 'bundle', 'exec', 'w2m'

    refute_predicate(status, :success?)
    assert_includes(output, 'Usage:')
  end

  should 'convert a document' do
    output, status = Open3.capture2e 'bundle', 'exec', 'w2m', fixture_path('em')

    assert_predicate(status, :success?)
    assert_includes(output, '_italic_')
  end
end
