# -*- encoding: utf-8 -*-
# stub: cliver 0.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "cliver".freeze
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryan Biesemeyer".freeze]
  s.date = "2013-12-13"
  s.description = "Assertions for command-line dependencies".freeze
  s.email = ["ryan@yaauie.com".freeze]
  s.homepage = "https://www.github.com/yaauie/cliver".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Cross-platform version constraints for cli tools".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 3

  s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<ruby-appraiser-reek>.freeze, [">= 0"])
  s.add_development_dependency(%q<ruby-appraiser-rubocop>.freeze, [">= 0"])
  s.add_development_dependency(%q<yard>.freeze, [">= 0"])
end
