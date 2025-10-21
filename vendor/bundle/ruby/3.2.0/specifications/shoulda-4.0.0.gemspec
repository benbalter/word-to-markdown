# -*- encoding: utf-8 -*-
# stub: shoulda 4.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "shoulda".freeze
  s.version = "4.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tammer Saleh".freeze, "Joe Ferris".freeze, "Ryan McGeary".freeze, "Dan Croak".freeze, "Matt Jankowski".freeze]
  s.date = "2020-06-13"
  s.description = "Making tests easy on the fingers and eyes".freeze
  s.email = "support@thoughtbot.com".freeze
  s.homepage = "https://github.com/thoughtbot/shoulda".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Making tests easy on the fingers and eyes".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<shoulda-context>.freeze, ["~> 2.0"])
  s.add_runtime_dependency(%q<shoulda-matchers>.freeze, ["~> 4.0"])
end
