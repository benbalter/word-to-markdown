lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require 'mocha/version'

Gem::Specification.new do |s|
  s.name = 'mocha'
  s.version = Mocha::VERSION
  s.licenses = ['MIT', 'BSD-2-Clause']
  s.required_ruby_version = '>= 1.9'

  s.authors = ['James Mead']
  s.description = 'Mocking and stubbing library with JMock/SchMock syntax, which allows mocking and stubbing of methods on real (non-mock) classes.'
  s.email = 'mocha-developer@googlegroups.com'

  s.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(docs|test)/}) }
  end
  s.files.delete('.circleci/config.yml')
  s.files.delete('.gitignore')

  s.homepage = 'https://mocha.jamesmead.org'
  s.require_paths = ['lib']
  s.summary = 'Mocking and stubbing library'
end
