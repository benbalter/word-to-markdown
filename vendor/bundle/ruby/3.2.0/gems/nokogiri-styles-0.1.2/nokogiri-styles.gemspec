# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nokogiri-styles/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Sijmen Mulder']
  gem.email         = ['sijmen@readmo.re']
  gem.summary       = %q{Basic inline CSS reading and editing for Nokogiri}
  gem.homepage      = ''

  gem.description   = <<-EOF
    NokgiriStyles lets you decompose inline CSS styling (the style attribute) in
    HTML elements so you don’t have to bother with regexes and such.
  EOF

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'nokogiri-styles'
  gem.require_paths = ['lib']
  gem.version       = NokogiriStyles::VERSION

  gem.add_dependency('nokogiri')
  gem.add_development_dependency('test-unit', '2.4.8')
end
