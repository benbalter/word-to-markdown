# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownCli < Minitest::Test
  should 'return usage information' do
    output, status = Open3.capture2e 'bundle', 'exec', 'w2m'

    refute_predicate(status, :success?)
    assert_includes(output, 'Usage:')
  end

  should 'exit successfully for --help' do
    output, status = Open3.capture2e 'bundle', 'exec', 'w2m', '--help'

    assert_predicate(status, :success?)
    assert_includes(output, 'Usage:')
  end

  should 'print versions for --version' do
    output, status = Open3.capture2e 'bundle', 'exec', 'w2m', '--version'

    assert_predicate(status, :success?)
    assert_includes(output, "WordToMarkdown v#{WordToMarkdown::VERSION}")
  end

  should 'reject unknown options' do
    output, status = Open3.capture2e 'bundle', 'exec', 'w2m', '--bogus'

    refute_predicate(status, :success?)
    assert_includes(output, 'invalid option: --bogus')
    assert_includes(output, 'Usage:')
  end

  should 'reject more than one path' do
    output, status = Open3.capture2e 'bundle', 'exec', 'w2m', fixture_path('em'), fixture_path('h1')

    refute_predicate(status, :success?)
    assert_includes(output, 'Usage:')
  end

  should 'convert a document' do
    output, status = Open3.capture2e 'bundle', 'exec', 'w2m', fixture_path('em')

    assert_predicate(status, :success?)
    assert_includes(output, '_italic_')
  end
end
