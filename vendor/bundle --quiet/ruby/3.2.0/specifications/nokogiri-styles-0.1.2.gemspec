# -*- encoding: utf-8 -*-
# stub: nokogiri-styles 0.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "nokogiri-styles".freeze
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sijmen Mulder".freeze]
  s.date = "2012-07-19"
  s.description = "    NokgiriStyles lets you decompose inline CSS styling (the style attribute) in\n    HTML elements so you don\u2019t have to bother with regexes and such.\n".freeze
  s.email = ["sijmen@readmo.re".freeze]
  s.homepage = "".freeze
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Basic inline CSS reading and editing for Nokogiri".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 3

  s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 0"])
  s.add_development_dependency(%q<test-unit>.freeze, ["= 2.4.8"])
end
