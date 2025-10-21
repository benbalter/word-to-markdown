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

def fixture_path(fixture = '')
  File.expand_path "fixtures/#{fixture}.docx", File.dirname(__FILE__)
end

def validate_fixture(fixture, expected)
  # Stub soffice to prevent "already running" errors in tests
  WordToMarkdown.soffice.stubs(:open?).returns(false)
  WordToMarkdown.soffice.stubs(:path).returns('/usr/bin/soffice')
  WordToMarkdown.soffice.stubs(:major_version).returns('6')
  assert_equal expected, WordToMarkdown.new(fixture_path(fixture)).to_s
end

def stub_doc(html)
  # Stub major_version and raw_html before creating the document
  WordToMarkdown.soffice.stubs(:major_version).returns('6')
  WordToMarkdown.soffice.stubs(:open?).returns(false)
  WordToMarkdown::Document.any_instance.stubs(:raw_html).returns(html)
  
  doc = WordToMarkdown.new 'test/fixtures/em.docx'
  tree = Nokogiri::HTML(doc.document.send(:normalized_html))
  doc.document.stubs(:tree).returns(tree)
  doc
end
