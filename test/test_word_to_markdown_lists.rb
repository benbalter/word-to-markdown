require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownLists < Test::Unit::TestCase

  should "properly parse unnumbered lists" do
    validate_fixture "ul", "- One\n- Two\n- Three"
  end

  should "properly parse numbered lists" do
    validate_fixture "ol", "1. One\n2. Two\n3. Three"
  end

  should "parse nested ols" do
    validate_fixture "nested-ol", "1. One\n  1. Sub one\n  2. Sub two\n\n3. Two\n  1. Sub one\n    1. Sub sub one\n    2. Sub sub two\n\n  3. Sub two\n\n4. Three"
  end

  should "parse nested uls" do
    validate_fixture "nested-ul", "- One\n  - Sub one\n    - Sub sub one\n    - Sub sub two\n\n  - Sub two\n\n- Two"
  end
end
