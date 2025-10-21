#!/usr/bin/env rake

require 'bundler/gem_tasks'
require 'rake'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/{functional,unit}/test_*.rb'
end
