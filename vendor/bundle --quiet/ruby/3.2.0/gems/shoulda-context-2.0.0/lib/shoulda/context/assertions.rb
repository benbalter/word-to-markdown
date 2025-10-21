module Shoulda # :nodoc:
  module Context
    module Assertions
      # Asserts that two arrays contain the same elements, the same number of times.  Essentially ==, but unordered.
      #
      #   assert_same_elements([:a, :b, :c], [:c, :a, :b]) => passes)
      def assert_same_elements(a1, a2, msg = nil)
        [:select, :inject, :size].each do |m|
          [a1, a2].each {|a| assert_respond_to(a, m, "Are you sure that #{a.inspect} is an array?  It doesn't respond to #{m}.") }
        end

        assert a1h = a1.inject({}) { |h,e| h[e] ||= a1.select { |i| i == e }.size; h }
        assert a2h = a2.inject({}) { |h,e| h[e] ||= a2.select { |i| i == e }.size; h }

        assert_equal(a1h, a2h, msg)
      end

      # Asserts that the given collection contains item x.  If x is a regular expression, ensure that
      # at least one element from the collection matches x.  +extra_msg+ is appended to the error message if the assertion fails.
      #
      #   assert_contains(['a', '1'], /\d/) => passes
      #   assert_contains(['a', '1'], 'a') => passes
      #   assert_contains(['a', '1'], /not there/) => fails
      def assert_contains(collection, x, extra_msg = "")
        collection = Array(collection)
        msg = "#{x.inspect} not found in #{collection.to_a.inspect} #{extra_msg}"
        case x
        when Regexp
          assert(collection.detect { |e| e =~ x }, msg)
        else
          assert(collection.include?(x), msg)
        end
      end

      # Asserts that the given collection does not contain item x.  If x is a regular expression, ensure that
      # none of the elements from the collection match x.
      def assert_does_not_contain(collection, x, extra_msg = "")
        collection = Array(collection)
        msg = "#{x.inspect} found in #{collection.to_a.inspect} " + extra_msg
        case x
        when Regexp
          assert(!collection.detect { |e| e =~ x }, msg)
        else
          assert(!collection.include?(x), msg)
        end
      end

      # Asserts that the given matcher returns true when +target+ is passed to
      # #matches?
      def assert_accepts(matcher, target, options = {})
        if matcher.respond_to?(:in_context)
          matcher.in_context(self)
        end

        if matcher.matches?(target)
          safe_assert_block { true }
          if options[:message]
            assert_match options[:message], matcher.failure_message_when_negated
          end
        else
          safe_assert_block(matcher.failure_message) { false }
        end
      end

      # Asserts that the given matcher returns true when +target+ is passed to
      # #does_not_match? or false when +target+ is passed to #matches? if
      # #does_not_match? is not implemented
      def assert_rejects(matcher, target, options = {})
        if matcher.respond_to?(:in_context)
          matcher.in_context(self)
        end

        not_match =
          if matcher.respond_to?(:does_not_match?)
            matcher.does_not_match?(target)
          else
            !matcher.matches?(target)
          end

        if not_match
          safe_assert_block { true }
          if options[:message]
            assert_match options[:message], matcher.failure_message
          end
        else
          safe_assert_block(matcher.failure_message_when_negated) { false }
        end
      end

      def safe_assert_block(message = "assert_block failed.", &block)
        if respond_to?(:assert_block)
          assert_block message, &block
        else
          assert yield, message
        end
      end
    end
  end
end
