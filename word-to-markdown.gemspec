# frozen_string_literal: true

require File.expand_path('lib/word-to-markdown/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'word-to-markdown'
  s.summary = 'Ruby Gem to convert Word documents to markdown'
  s.description = 'Ruby Gem to convert Word documents to markdown.'
  s.version = WordToMarkdown::VERSION
  s.authors = ['Ben Balter']
  s.email = 'ben.balter@github.com'
  s.homepage = 'https://github.com/benbalter/word-to-markdown'
  s.licenses = ['MIT']
  s.files = Dir['{bin,lib}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")

  s.bindir = 'bin'
  s.executables = ['w2m']

  s.add_dependency('cliver', '~> 0.3')
  s.add_dependency('descriptive_statistics', '~> 2.5')
  s.add_dependency('nokogiri-styles', '~> 0.1')
  s.add_dependency('premailer', '~> 1.8')
  s.add_dependency('reverse_markdown', '>= 1', '< 3')
  s.add_dependency('sys-proctable', '~> 1.0')

  s.add_development_dependency('minitest', '~> 5.0')
  s.add_development_dependency('mocha', '~> 1.1')
  s.add_development_dependency('pry', '~> 0.10')
  s.add_development_dependency('rake', '~> 13.0')
  s.add_development_dependency('rubocop', '~> 1.0')
  s.add_development_dependency('rubocop-minitest', '~> 0.3')
  s.add_development_dependency('rubocop-performance', '~> 1.5')
  s.add_development_dependency('shoulda', '~> 4.0')
  s.metadata['rubygems_mfa_required'] = 'true'
end
