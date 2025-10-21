require "test_helper"

class RailtieTest < PARENT_TEST_CASE
  context "A Rails application with shoulda-context added to it" do
    setup do
      app.create
    end

    should "load files in vendor/gems and vendor/plugins when booted" do
      app.create_gem_with_macro(
        module_name: "MacrosFromVendor",
        location: "vendor/gems/vendored_gem_with_macro",
        macro_name: "macro_from_vendored_gem"
      )
      app.create_gem_with_macro(
        module_name: "MacrosFromPlugin",
        location: "vendor/plugins/plugin_gem_with_macro",
        macro_name: "macro_from_plugin_gem"
      )
      app.create_gem_with_macro(
        module_name: "MacrosFromTest",
        location: "test",
        macro_name: "macro_from_test"
      )
      app.write_file("test/macros_test.rb", <<~RUBY)
        ENV["RAILS_ENV"] = "test"
        require_relative "../config/environment"

        class MacrosTest < #{PARENT_TEST_CASE}
          macro_from_vendored_gem
          macro_from_plugin_gem
          macro_from_test
        end
      RUBY

      app.run_n_unit_test_suite
    end
  end

  def app
    @_app ||= RailsApplicationWithShouldaContext.new
  end
end
