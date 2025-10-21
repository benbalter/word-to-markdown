require "test_helper"

class RerunSnippetTest < PARENT_TEST_CASE
  context "A Rails application with shoulda-context added to it" do
    should "display the correct rerun snippet when a test fails" do
      if app.rails_version >= 5 && TEST_FRAMEWORK == "minitest"
        app.create

        app.write_file("test/models/failing_test.rb", <<~RUBY)
          ENV["RAILS_ENV"] = "test"
          require_relative "../../config/environment"

          class FailingTest < #{PARENT_TEST_CASE}
            should "fail" do
              assert false
            end
          end
        RUBY

        command_runner = app.run_n_unit_test_suite

        expected_file_path_with_line_number =
          if rails_version >= 6
            "rails test test/models/failing_test.rb:5"
          else
            "bin/rails test test/models/failing_test.rb:5"
          end

        assert_includes(
          command_runner.output,
          expected_file_path_with_line_number
        )
      end
    end
  end

  def app
    @_app ||= RailsApplicationWithShouldaContext.new
  end

  def rails_version
    # TODO: Update snowglobe so that we don't have to do this
    app.send(:bundle).version_of("rails")
  end
end
