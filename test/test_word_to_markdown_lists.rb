# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownLists < Minitest::Test
  should 'properly parse unnumbered lists' do
    validate_fixture 'ul', "- One\n- Two\n- Three"
  end

  should 'properly parse numbered lists' do
    validate_fixture 'ol', "1. One\n2. Two\n3. Three"
  end

  should 'parse nested ols' do
    validate_fixture 'nested-ol', "1. One\n  1. Sub one\n  2. Sub two\n2. Two\n  1. Sub one\n    1. Sub sub one\n    2. Sub sub two\n  2. Sub two\n3. Three"
  end

  should 'parse nested uls' do
    validate_fixture 'nested-ul', "- One\n  - Sub one\n    - Sub sub one\n    - Sub sub two\n  - Sub two\n- Two"
  end

  should 'parse lists with links' do
    validate_fixture 'list-with-links', "[word-to-markdown](https://github.com/benbalter/word-to-markdown)\n\n- [word-to-markdown](https://github.com/benbalter/word-to-markdown)"
  end
end
