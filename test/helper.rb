require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'mocha/test_unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'word-to-markdown'

def fixture_path(fixture="")
  File.expand_path "fixtures/#{fixture}.docx", File.dirname(__FILE__)
end

def validate_fixture(fixture, expected)
  assert_equal expected, WordToMarkdown.new(fixture_path(fixture)).to_s
end

def stub_doc(html)
  doc = WordToMarkdown.new "test/fixtures/em.docx"
  tree = Nokogiri::HTML(doc.document.normalize(html))
  doc.document.stubs(:tree).returns(tree)
  doc
end
