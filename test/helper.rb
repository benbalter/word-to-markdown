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
  assert_equal expected, WordToMarkdown.new(fixture_path(fixture)).to_s
end

def stub_doc(html)
  doc = WordToMarkdown.new 'test/fixtures/em.docx'
  doc.document.stubs(:raw_html).returns(html)
  tree = Nokogiri::HTML(doc.document.send(:normalized_html))
  doc.document.stubs(:tree).returns(tree)
  doc
end
