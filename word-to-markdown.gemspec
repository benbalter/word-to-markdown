require_relative 'lib/word-to-markdown/version'

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
    "lib/word-to-markdown/document.rb",
    "lib/word-to-markdown/converter.rb",
    "lib/nokogiri/xml/element.rb"
  ]
  s.executables = ["w2m"]
  s.add_dependency("reverse_markdown","~> 0.4.7")
  s.add_dependency('descriptive_statistics', "~> 1.1.3")
  s.add_dependency( "premailer" )
  s.add_dependency( 'nokogiri-styles' )
  s.add_development_dependency( "rake" )
  s.add_development_dependency( "shoulda" )
  s.add_development_dependency( "rdoc" )
  s.add_development_dependency( "bundler" )
  s.add_development_dependency( "pry" )
  s.add_development_dependency( "mocha" )
  s.add_development_dependency( "minitest", "~> 4.7" )

end
