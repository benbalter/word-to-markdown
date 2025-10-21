module Shoulda
  module Context
    module TestFrameworkDetection
      def self.possible_test_frameworks
        [
          -> { ActiveSupport::TestCase },
          -> { Minitest::Test },
          -> { Test::Unit::TestCase }
        ]
      end

      def self.resolve_framework(future_framework)
        future_framework.call
      rescue NameError
        nil
      end

      def self.detected_test_framework_test_cases
        possible_test_frameworks.
          map { |future_framework| resolve_framework(future_framework) }.
          compact
      end

      def self.test_framework_test_cases
        @_test_framework_test_cases ||= detected_test_framework_test_cases
      end
    end

    def self.test_framework_test_cases
      TestFrameworkDetection.test_framework_test_cases
    end
  end
end
