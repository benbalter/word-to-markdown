require "test_helper"
require "tempfile"

class TestFrameworkDetectionTest < PARENT_TEST_CASE
  if Tests::CurrentBundle.instance.current_appraisal == "rails_5_2"
    should "detect Minitest 5.x w/ Rails 5.2" do
      assert_integration_with_rails_and "Minitest::Test"
    end
  end

  if Tests::CurrentBundle.instance.current_appraisal == "rails_5_1"
    should "detect Minitest 5.x w/ Rails 5.1" do
      assert_integration_with_rails_and "Minitest::Test"
    end
  end

  if Tests::CurrentBundle.instance.current_appraisal == "rails_5_0"
    should "detect Minitest 5.x w/ Rails 5.0" do
      assert_integration_with_rails_and "Minitest::Test"
    end
  end

  if Tests::CurrentBundle.instance.current_appraisal == "rails_4_2"
    should "detect ActiveSupport::TestCase and Minitest 4.x w/ Rails 4.2" do
      assert_integration_with_rails_and "Minitest::Test"
    end
  end

  if TEST_FRAMEWORK == "minitest"
    should "detect Minitest 5.x when it is loaded standalone" do
      assert_integration_with "Minitest::Test", setup: <<-RUBY
        require "minitest/autorun"
      RUBY
    end
  end

  if TEST_FRAMEWORK == "test_unit"
    should "detect the test-unit gem when it is loaded standalone" do
      assert_integration_with "Test::Unit::TestCase",
        setup: <<-RUBY
          require "test/unit"
        RUBY
    end
  end

  def assert_integration_with_rails_and(*test_cases)
    test_cases = ["ActiveSupport::TestCase"] | test_cases
    options = test_cases.last.is_a?(Hash) ? test_cases.pop : {}
    options[:setup] = <<-RUBY
      require "rails/all"
      require "rails/test_help"
      ActiveRecord::Base.establish_connection(
        adapter: "sqlite3",
        database: ":memory:"
      )
    RUBY
    args = test_cases + [options]

    assert_integration_with(*args)
  end

  def assert_integration_with(*test_cases)
    assert_test_cases_are_detected(*test_cases)
    assert_our_api_is_available_in_test_cases(*test_cases)
  end

  def assert_test_cases_are_detected(*expected_test_cases)
    options = expected_test_cases.last.is_a?(Hash) ? expected_test_cases.pop : {}
    setup = options[:setup] || ""
    output = execute(file_that_detects_test_framework_test_cases([setup]))
    actual_test_cases = output.split("\n").first.split(", ")
    assert_equal expected_test_cases, actual_test_cases
  end

  def file_that_detects_test_framework_test_cases(mixins)
    <<-RUBY
      #{require_gems(mixins)}
      require "yaml"
      test_cases =
      Shoulda::Context.test_framework_test_cases.map do |test_case|
        test_case.to_s
      end
      puts test_cases.join(', ')
    RUBY
  end

  def require_gems(mixins)
    <<-RUBY
      ENV["BUNDLE_GEMFILE"] =
        "#{PROJECT_DIR}/gemfiles/" +
        "#{Tests::CurrentBundle.instance.current_appraisal}.gemfile"
      require "bundler"
      Bundler.setup
      #{mixins.join("\n")}
      require "shoulda-context"
    RUBY
  end

  def assert_our_api_is_available_in_test_cases(*test_cases)
    options = test_cases.last.is_a?(Hash) ? test_cases.pop : {}
    setup = options[:setup] || ""

    test_cases.each do |test_case|
      output = execute(
        file_that_runs_a_test_within_test_case(test_case, [setup])
      )
      assert_match(/1 (tests|runs)/, output)
      assert_match(/1 assertions/, output)
      assert_match(/0 failures/, output)
      assert_match(/0 errors/, output)
    end
  end

  def file_that_runs_a_test_within_test_case(test_case, mixins)
    <<-RUBY
      #{require_gems(mixins)}

      class FrameworkIntegrationTest < #{test_case}
        context "a context" do
          should "have a test" do
            assert_equal true, true
          end
        end
      end
    RUBY
  end

  def execute(code)
    tempfile = Tempfile.new("shoulda-context-test")
    tempfile.write(code)
    tempfile.close

    if ENV["DEBUG"]
      puts "Code:"
      puts code
    end

    output = `RUBYOPT="" ruby #{tempfile.path} 2>/dev/null`

    if ENV["DEBUG"]
      puts "Output:"
      puts output
    end

    output
  end
end
