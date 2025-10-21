# -*- encoding: utf-8 -*-

$LOAD_PATH << File.join(File.dirname(__FILE__), "lib")
require "shoulda/context/version"

Gem::Specification.new do |s|
  s.name        = "shoulda-context"
  s.version     = Shoulda::Context::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["thoughtbot, inc.", "Tammer Saleh", "Joe Ferris",
                   "Ryan McGeary", "Dan Croak", "Matt Jankowski"]
  s.email       = "support@thoughtbot.com"
  s.homepage    = "http://thoughtbot.com/community/"
  s.summary     = "Context framework extracted from Shoulda"
  s.description = "Context framework extracted from Shoulda"
  s.license     = "MIT"

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- exe/*`.split("\n").map { |f| File.basename(f) }
  s.bindir           = "exe"
  s.require_paths    = ["lib"]
end
