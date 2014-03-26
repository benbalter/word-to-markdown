require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownLists < Test::Unit::TestCase

  should "properly parse unnumbered lists" do
    validate_fixture "ul", "- One\n- Two\n- Three"
  end

  should "properly parse numbered lists" do
    validate_fixture "ol", "1. One\n\n2. Two\n\n3. Three"
  end

  should "not wrap ol in uls" do
    validate_fixture "ul-ol", "1. One\n2. Two"
  end
  
end
