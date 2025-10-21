begin
  require "rails/test_unit/reporter"

  Rails::TestUnitReporter.class_eval do
    # Fix #format_rerun_snippet so that it works with recent versions of Minitest.
    # This was cribbed from:
    # <https://github.com/rails/rails/commit/ff0d5f14504f1aa29ad908ab15bab66b101427b7#diff-a071a1c8f51ce3b8bcb17ca59c79fc70>
    def format_rerun_snippet(result)
      location, line =
        if result.respond_to?(:source_location)
          result.source_location
        else
          result.method(result.name).source_location
        end

      "#{executable} #{relative_path_for(location)}:#{line}"
    end
  end
rescue LoadError
  # Rails::TestUnitReporter was introduced in Rails 5
end
