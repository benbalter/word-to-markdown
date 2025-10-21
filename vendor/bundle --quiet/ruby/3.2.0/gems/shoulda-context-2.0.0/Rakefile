require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
require "pry-byebug"

require_relative "test/support/current_bundle"

load "tasks/shoulda.rake"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.ruby_opts += ["-w"]
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end

task :default do
  if Tests::CurrentBundle.instance.appraisal_in_use?
    Rake::Task["test"].invoke
  elsif ENV["CI"]
    exec "appraisal install && appraisal rake --trace"
  else
    appraisal = Tests::CurrentBundle.instance.latest_appraisal
    exec "appraisal install && appraisal #{appraisal} rake --trace"
  end
end
