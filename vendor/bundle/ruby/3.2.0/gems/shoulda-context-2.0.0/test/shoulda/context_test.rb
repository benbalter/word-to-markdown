require 'test_helper'

class ContextTest < PARENT_TEST_CASE
  def self.context_macro(&blk)
    context "with a subcontext made by a macro" do
      setup { @context_macro = :foo }

      merge_block(&blk)
    end
  end

  context "context with setup block" do
    setup do
      @blah = "blah"
    end

    should "run the setup block" do
      assert_equal "blah", @blah
    end

    should "have name set right" do
      assert_match(/^test: context with setup block/, normalized_name)
    end

    context "and a subcontext" do
      setup do
        @blah = "#{@blah} twice"
      end

      should "be named correctly" do
        assert_match(/^test: context with setup block and a subcontext should be named correctly/, normalized_name)
      end

      should "run the setup blocks in order" do
        assert_equal @blah, "blah twice"
      end
    end

    context_macro do
      should "have name set right" do
        assert_match(/^test: context with setup block with a subcontext made by a macro should have name set right/, normalized_name)
      end

      should "run the setup block of that context macro" do
        assert_equal :foo, @context_macro
      end

      should "run the setup block of the main context" do
        assert_equal "blah", @blah
      end
    end

  end

  context "another context with setup block" do
    setup do
      @blah = "foo"
    end

    should "have @blah == 'foo'" do
      assert_equal "foo", @blah
    end

    should "have name set right" do
      assert_match(/^test: another context with setup block/, normalized_name)
    end
  end

  context "context with method definition" do
    setup do
      def hello; "hi"; end
    end

    should "be able to read that method" do
      assert_equal "hi", hello
    end

    should "have name set right" do
      assert_match(/^test: context with method definition/, normalized_name)
    end
  end

  context "another context" do
    should "not define @blah" do
      assert !instance_variable_defined?(:@blah)
    end
  end

  context "context with multiple setups and/or teardowns" do

    cleanup_count = 0

    2.times do |i|
      setup { cleanup_count += 1 }
      teardown { cleanup_count -= 1 }
    end

    2.times do |i|
      should "call all setups and all teardowns (check ##{i + 1})" do
        assert_equal 2, cleanup_count
      end
    end

    context "subcontexts" do

      2.times do |i|
        setup { cleanup_count += 1 }
        teardown { cleanup_count -= 1 }
      end

      2.times do |i|
        should "also call all setups and all teardowns in parent and subcontext (check ##{i + 1})" do
          assert_equal 4, cleanup_count
        end
      end

    end

  end

  should_eventually "pass, since it's unimplemented" do
    flunk "what?"
  end

  should_eventually "not require a block when using should_eventually"
  should "pass without a block, as that causes it to piggyback to should_eventually"

  context "context for testing should piggybacking" do
    should "call should_eventually as we are not passing a block"
  end

  context "context" do
    context "with nested subcontexts" do
      should_eventually "only print this statement once for a should_eventually"
    end
  end

  class ::SomeModel; end

  context "given a test named after a class" do
    setup do
      self.class.stubs(:name).returns("SomeModelTest")
    end

    should "determine the described type" do
      assert_equal SomeModel, self.class.described_type
    end

    should "return a new instance of the described type as the subject if none exists" do
      assert_kind_of SomeModel, subject
    end

    context "with an explicit subject block" do
      setup { @expected = SomeModel.new }
      subject { @expected }
      should "return the result of the block as the subject" do
        assert_equal @expected, subject
      end

      context "nested context block without a subject block" do
        should "return the result of the parent context's subject block" do
          assert_equal @expected, subject
        end
      end
    end
  end

  def normalized_name
    name.sub("test_:", "test:")
  end
end

class ::Some
  class NestedModel; end
end

class Some::NestedModelTest < PARENT_TEST_CASE
  should "determine the described type for a nested model" do
    assert_equal Some::NestedModel, self.class.described_type
  end
end

class Some::SomeTest < PARENT_TEST_CASE
  should "not fallback to higher-level constants with same name" do
    assert_raises(NameError) do
      assert_equal nil, self.class.described_type
    end
  end
end

class ShouldMatcherTest < PARENT_TEST_CASE
  class FakeMatcher
    attr_reader :subject
    attr_accessor :fail

    def description
      "be a fake matcher"
    end

    def matches?(subject)
      @subject = subject
      !@fail
    end

    def failure_message
      "positive failure message"
    end

    def failure_message_when_negated
      "negative failure message"
    end
  end

  def setup
    @matcher = FakeMatcher.new
  end

  def assert_failed_with(message, test_suite)
    assert_equal [message], test_suite.failure_messages
  end

  def assert_passed(test_suite)
    assert_equal [], test_suite.failure_messages
  end

  def assert_test_named(expected_name, test_suite)
    name = test_suite.test_names.first
    assert(
      name.include?(expected_name),
      "Expected #{name} to include #{expected_name}"
    )
  end

  def self.should_use_positive_matcher
    should "generate a test using the matcher's description" do
      assert_test_named "should #{@matcher.description}", @test_suite
    end

    should "pass with a passing matcher" do
      @matcher.fail = false
      @test_suite.run
      assert_passed @test_suite
    end

    should "fail with a failing matcher" do
      @matcher.fail = true
      @test_suite.run
      assert_failed_with "positive failure message", @test_suite
    end

    should "provide the subject" do
      @matcher.fail = false
      @test_suite.run
      assert_equal 'a subject', @matcher.subject
    end
  end

  def self.should_use_negative_matcher
    should "generate a test using the matcher's description" do
      assert_test_named "should not #{@matcher.description}", @test_suite
    end

    should "pass with a failing matcher" do
      @matcher.fail = true
      @test_suite.run
      assert_passed @test_suite
    end

    should "fail with a passing matcher" do
      @matcher.fail = false
      @test_suite.run
      assert_failed_with "negative failure message", @test_suite
    end

    should "provide the subject" do
      @matcher.fail = false
      @test_suite.run
      assert_equal 'a subject', @matcher.subject
    end
  end

  context "a should block with a matcher" do
    setup do
      matcher = @matcher
      @test_suite = TestSuite.create do
        subject { 'a subject' }
        should matcher
      end
    end

    should_use_positive_matcher
  end

  context "a should block with a matcher within a context" do
    setup do
      matcher = @matcher
      @test_suite = TestSuite.create do
        context "in context" do
          subject { 'a subject' }
          should matcher
        end
      end
    end

    should_use_positive_matcher
  end

  context "a should_not block with a matcher" do
    setup do
      matcher = @matcher
      @test_suite = TestSuite.create do
        subject { 'a subject' }
        should_not matcher
      end
    end

    should_use_negative_matcher
  end

  context "a should_not block with a matcher within a context" do
    setup do
      matcher = @matcher
      @test_suite = TestSuite.create do
        context "in context" do
          subject { 'a subject' }
          should_not matcher
        end
      end
    end

    should_use_negative_matcher
  end

  class TestSuite
    def self.create(&definition)
      if defined?(Test::Unit)
        TestUnitSuite.new(&definition)
      else
        MinitestSuite.new(&definition)
      end
    end
  end

  class TestUnitSuite
    def initialize(&definition)
      @suite = Class.new(Test::Unit::TestCase, &definition).suite
      @result = Test::Unit::TestResult.new
    end

    def run
      @suite.run(@result) do |event, name|
        # do nothing
      end
    end

    def failure_messages
      @result.failures.map(&:message)
    end

    def test_names
      @suite.tests.map(&:method_name)
    end
  end

  class MinitestSuite
    def initialize(&definition)
      @test_case_class = Class.new(Minitest::Test, &definition)
      @reporter = Minitest::StatisticsReporter.new(StringIO.new)
    end

    def run
      @test_case_class.run(@reporter)
    end

    def failure_messages
      @reporter.results.flat_map(&:failures).map(&:message)
    end

    def test_names
      @test_case_class.runnable_methods
    end
  end
end

class Subject; end

class SubjectTest < PARENT_TEST_CASE

  def setup
    @expected = Subject.new
  end

  subject { @expected }

  should "return a specified subject" do
    assert_equal @expected, subject
  end
end

class SubjectLazinessTest < PARENT_TEST_CASE
  subject { Subject.new }

  should "only build the subject once" do
    assert_equal subject, subject
  end
end
