# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_word_to_markdown*.rb'
end

task default: :test
