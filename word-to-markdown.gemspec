Gem::Specification.new do |s|
  s.name = "word-to-markdown"
  s.summary = "Ruby Gem to convert Word documents to markdown"
  s.description = "Ruby Gem to convert Word documents to markdown."
  s.version = "0.0.4"
  s.authors = ["Ben Balter"]
  s.email = "ben.balter@github.com"
  s.homepage = "https://github.com/benbalter/word-to-markdown"
  s.licenses = ["MIT"]
  s.files = [ "lib/word-to-markdown.rb" ]
  s.add_dependency("reverse_markdown","~> 0.4.7")
  s.add_dependency('descriptive_statistics', "~> 1.1.3")
  s.add_dependency( "premailer" )
  s.add_dependency( 'nokogiri-styles' )
  s.add_dependency( 'roman-numerals' )
  s.add_development_dependency( "rake" )
  s.add_development_dependency( "shoulda" )
  s.add_development_dependency( "rdoc" )
  s.add_development_dependency( "bundler" )
  s.add_development_dependency( "pry" )
  s.add_development_dependency( "rerun" )
end
