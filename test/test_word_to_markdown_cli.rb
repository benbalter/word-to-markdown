require File.join(File.dirname(__FILE__), 'helper')

class TestWordToMarkdownCli < Test::Unit::TestCase
  should "return usage information" do
    output, status = Open3.capture2e "bundle", "exec", "w2m"
    assert_equal false, status.success?
    assert_equal true, output.include?("Usage:")
  end

  should "convert a document" do
    output, status = Open3.capture2e  "bundle", "exec", "w2m", fixture_path("em")
    assert_equal true, status.success?
    assert_equal true, output.include?("_italic_")
  end
end
