require_relative "support/current_bundle"

Tests::CurrentBundle.instance.assert_appraisal!

#---

require "pry-byebug"
require "warnings_logger"

TEST_FRAMEWORK = ENV.fetch("TEST_FRAMEWORK", "minitest")

if TEST_FRAMEWORK == "test_unit"
  require "test-unit"
  require "mocha/test_unit"
else
  require "minitest/autorun"
  require "mocha/minitest"
end

PROJECT_DIR = File.expand_path("../..", __FILE__)
PARENT_TEST_CASE =
  if TEST_FRAMEWORK == "test_unit"
    Test::Unit::TestCase
  else
    Minitest::Test
  end
ASSERTION_CLASS =
  if TEST_FRAMEWORK == "test_unit"
    Test::Unit::AssertionFailedError
  else
    Minitest::Assertion
  end

WarningsLogger::Spy.call(
  project_name: "shoulda-context",
  project_directory: Pathname.new("../..").expand_path(__FILE__)
)

require_relative "support/rails_application_with_shoulda_context"

require_relative "../lib/shoulda/context"

Shoulda.autoload_macros(
  File.join(File.dirname(__FILE__), "fake_rails_root"),
  File.join("vendor", "{plugins,gems}", "*")
)

$VERBOSE = true
