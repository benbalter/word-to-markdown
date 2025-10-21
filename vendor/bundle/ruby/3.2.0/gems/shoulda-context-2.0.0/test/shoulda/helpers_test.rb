require 'test_helper'

class HelpersTest < PARENT_TEST_CASE
  context "an array of values" do
    setup do
      @a = ['abc', 'def', 3]
    end

    [/b/, 'abc', 3].each do |x|
      should "contain #{x.inspect}" do
        assert_raises(ASSERTION_CLASS) do
          assert_does_not_contain @a, x
        end
        assert_contains @a, x
      end
    end

    should "not contain 'wtf'" do
      assert_raises(ASSERTION_CLASS) {assert_contains @a, 'wtf'}
      assert_does_not_contain @a, 'wtf'
    end

    should "be the same as another array, ordered differently" do
      assert_same_elements(@a, [3, "def", "abc"])
      assert_raises(ASSERTION_CLASS) do
        assert_same_elements(@a, [3, 3, "def", "abc"])
      end
      assert_same_elements([@a, "abc"].flatten, ["abc", 3, "def", "abc"])
      assert_raises(ASSERTION_CLASS) do
        assert_same_elements([@a, "abc"].flatten, [3, 3, "def", "abc"])
      end
    end

    should "only count the number of occurrences once for each unique value" do
      a1 = [@a, "abc"].flatten
      a1.expects(:select).times(3).returns(["abc", "abc"], ["def"], [3])
      assert_same_elements(a1, ["abc", 3, "def", "abc"])
    end
  end

  context "a matching matcher" do
    setup do
      @matcher = stub(
        "matcher",
        matches?: true,
        failure_message: "bad failure message",
        failure_message_when_negated: "big time failure"
      )
    end

    should "pass when given to assert_accepts with no message expectation" do
      assert_accepts @matcher, 'target'
    end

    should "pass when given to assert_accepts with a matching message" do
      assert_accepts @matcher, 'target', :message => /big time/
    end

    should "fail when given to assert_accepts with non-matching message" do
      assert_raises ASSERTION_CLASS do
        assert_accepts @matcher, 'target', :message => /small time/
      end
    end

    context "when given to assert_rejects" do
      context "and matcher has :does_not_match?" do
        setup do
          @error = nil
          begin
            @matcher.stubs(:matches?).returns(false)
            @matcher.stubs(:does_not_match?).returns(true)
            assert_rejects @matcher, 'target'
          rescue ASSERTION_CLASS => @error
          end
        end

        should "pass" do
          assert_nil @error
        end
      end

      context "and matcher does not have :does_not_match?" do
        setup do
          @error = nil
          begin
            assert_rejects @matcher, 'target'
          rescue ASSERTION_CLASS => @error
          end
        end

        should "fail" do
          refute_nil @error
        end

        should "use the error message from the matcher" do
          assert_equal 'big time failure', @error.message
        end
      end
    end
  end

  context "a non-matching matcher" do
    setup do
      @matcher = stub(
        "matcher",
        matches?: false,
        failure_message: "big time failure",
        failure_message_when_negated: "bad failure message"
      )
    end

    should "pass when given to assert_rejects with no message expectation" do
      assert_rejects @matcher, 'target'
    end

    should "pass when given to assert_rejects with a matching message" do
      assert_rejects @matcher, 'target', :message => /big time/
    end

    should "fail when given to assert_rejects with a non-matching message" do
      assert_raises ASSERTION_CLASS do
        assert_rejects @matcher, 'target', :message => /small time/
      end
    end

    context "when given to assert_accepts" do
      setup do
        begin
          assert_accepts @matcher, 'target'
        rescue ASSERTION_CLASS => @error
        end
      end

      should "fail" do
        refute_nil @error
      end

      should "use the error message from the matcher" do
        assert_equal 'big time failure', @error.message
      end
    end
  end

  should "assign context to a support matching on assert_accepts" do
    matcher = stub('matcher', :matches? => true)
    matcher.expects(:in_context).with(self)
    assert_accepts matcher, nil
  end

  should "assign context to a support matching on assert_rejects" do
    matcher = stub('matcher', :matches? => false)
    matcher.expects(:in_context).with(self)
    assert_rejects matcher, nil
  end
end
