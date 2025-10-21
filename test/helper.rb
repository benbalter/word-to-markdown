# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/minitest'
require 'shoulda'
require 'open3'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'word-to-markdown'

# Global stubbing to prevent LibreOffice calls in tests
# These stubs allow tests to run without LibreOffice installed
module GlobalStubs
  def setup
    super if defined?(super)
    # Stub soffice methods globally for all tests
    WordToMarkdown.soffice.stubs(:open?).returns(false)
    WordToMarkdown.soffice.stubs(:path).returns('/usr/bin/soffice')
    WordToMarkdown.soffice.stubs(:major_version).returns('6')
  end
end

# Include global stubs in Minitest::Test
class Minitest::Test
  prepend GlobalStubs
end

def fixture_path(fixture = '')
  File.expand_path "fixtures/#{fixture}.docx", File.dirname(__FILE__)
end

def validate_fixture(fixture, expected)
  assert_equal expected, WordToMarkdown.new(fixture_path(fixture)).to_s
end

def stub_doc(html)
  # Stub raw_html before creating the document
  WordToMarkdown::Document.any_instance.stubs(:raw_html).returns(html)
  
  doc = WordToMarkdown.new 'test/fixtures/em.docx'
  tree = Nokogiri::HTML(doc.document.send(:normalized_html))
  doc.document.stubs(:tree).returns(tree)
  doc
end
