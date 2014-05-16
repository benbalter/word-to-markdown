require File.expand_path('../lib/word-to-markdown/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "word-to-markdown"
  s.summary = "Ruby Gem to convert Word documents to markdown"
  s.description = "Ruby Gem to convert Word documents to markdown."
  s.version = WordToMarkdown::VERSION
  s.authors = ["Ben Balter"]
  s.email = "ben.balter@github.com"
  s.homepage = "https://github.com/benbalter/word-to-markdown"
  s.licenses = ["MIT"]
  s.files = [
    "lib/word-to-markdown.rb",
    "lib/word-to-markdown/version.rb",
    "lib/word-to-markdown/document.rb",
    "lib/word-to-markdown/converter.rb",
    "lib/nokogiri/xml/element.rb",
    "bin/w2m"
  ]
  s.executables = ["w2m"]
  s.add_dependency("reverse_markdown","~> 0.5")
  s.add_dependency('descriptive_statistics', "~> 1.1")
  s.add_dependency( "premailer", "~> 1.8" )
  s.add_dependency( 'nokogiri-styles', "~> 0.1")
  s.add_development_dependency( "rake", "~> 10.3")
  s.add_development_dependency( "shoulda", "~> 3.5")
  s.add_development_dependency( "rdoc", "~> 4.1")
  s.add_development_dependency( "bundler", "~> 1.6")
  s.add_development_dependency( "pry", "~> 0.9")
  s.add_development_dependency( "mocha", "~> 1.0" )
  s.add_development_dependency( "minitest", "~> 4.7" )
end
