# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'rake'
require 'rake/testtask'
require './lib/word-to-markdown'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
end
