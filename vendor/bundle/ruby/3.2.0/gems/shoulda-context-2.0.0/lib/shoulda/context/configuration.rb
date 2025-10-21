module Shoulda
  module Context
    def self.configure
      yield self
    end

    def self.include(mod)
      test_framework_test_cases.each do |test_case|
        test_case.class_eval { include mod }
      end
    end

    def self.extend(mod)
      test_framework_test_cases.each do |test_case|
        test_case.extend(mod)
      end
    end
  end
end
