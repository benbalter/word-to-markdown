require 'test_helper'

class ShouldTest < PARENT_TEST_CASE
  should "be able to define a should statement outside of a context" do
    assert true
  end

  should "see the name of my class as ShouldTest" do
    assert_equal "ShouldTest", self.class.name
  end

  def self.should_see_class_methods
    should "be able to see class methods" do
      assert true
    end
  end

  def self.should_be_able_to_setup_a_should_eventually_in_a_class_method
    should "be able to setup a should eventually in a class method"
  end

  def self.should_see_a_context_block_like_a_test_case_class
    should "see a context block as a Test::Unit class" do
      assert_equal "ShouldTest", self.class.name
    end
  end

  def self.should_see_blah
    should "see @blah through a macro" do
      assert @blah
    end
  end

  def self.should_not_see_blah
    should "not see @blah through a macro" do
      assert !instance_variable_defined?(:@blah)
    end
  end

  def self.should_be_able_to_make_context_macros(prefix = nil)
    context "a macro" do
      should "have the tests named correctly" do
        assert_match(
          Regexp.new(
            "^" +
            build_expected_test_name(
              "#{prefix}a macro should have the tests named correctly"
            )
          ),
          test_name
        )
      end
    end
  end

  context "Context" do
    should_see_class_methods
    should_see_a_context_block_like_a_test_case_class
    should_be_able_to_make_context_macros("Context ")
    should_be_able_to_setup_a_should_eventually_in_a_class_method

    should "not define @blah" do
      assert ! self.instance_variables.include?("@blah")
    end

    should_not_see_blah

    should "be able to define a should statement" do
      assert true
    end

    should "see the name of my class as ShouldTest" do
      assert_equal "ShouldTest", self.class.name
    end

    context "with a subcontext" do
      should_be_able_to_make_context_macros("Context with a subcontext ")
    end
  end

  context "Context with setup block" do
    setup do
      @blah = "blah"
    end

    should "have @blah == 'blah'" do
      assert_equal "blah", @blah
    end
    should_see_blah

    should "have name set right" do
      assert_match(
        Regexp.new(
          "^" +
          build_expected_test_name("Context with setup block")
        ),
        test_name
      )
    end

    context "and a subcontext" do
      setup do
        @blah = "#{@blah} twice"
      end

      should "be named correctly" do
        assert_match(
          Regexp.new(
            "^" +
            build_expected_test_name(
              "Context with setup block and a subcontext should be named correctly"
            )
          ),
          test_name
        )
      end

      should "run the setup methods in order" do
        assert_equal @blah, "blah twice"
      end
      should_see_blah
    end
  end

  context "Another context with setup block" do
    setup do
      @blah = "foo"
    end

    should "have @blah == 'foo'" do
      assert_equal "foo", @blah
    end

    should "have name set right" do
      assert_match(
        Regexp.new(
          "^" +
          build_expected_test_name("Another context with setup block")
        ),
        test_name
      )
    end
    should_see_blah
  end

  should_eventually "pass, since it's a should_eventually" do
    flunk "what?"
  end

  # Context creation and naming

  def test_should_create_a_new_context
    assert_nothing_raised do
      Shoulda::Context::Context.new("context name", self.class) do; end
    end
  end

  def test_should_create_a_new_context_even_if_block_is_omitted
    old_verbose, $VERBOSE = $VERBOSE, nil
    assert_nothing_raised do
      Shoulda::Context::Context.new("context without a block", self.class)
    end
  ensure
    $VERBOSE = old_verbose
  end

  def test_should_create_a_nested_context
    assert_nothing_raised do
      parent = Shoulda::Context::Context.new("Parent", self.class) do; end
      child  = Shoulda::Context::Context.new("Child", parent) do; end
      raise unless child.instance_of? Shoulda::Context::Context
    end
  end

  def test_should_name_a_contexts_correctly
    parent     = Shoulda::Context::Context.new("Parent", self.class) do; end
    child      = Shoulda::Context::Context.new("Child", parent) do; end
    grandchild = Shoulda::Context::Context.new("GrandChild", child) do; end

    assert_equal "Parent", parent.full_name
    assert_equal "Parent Child", child.full_name
    assert_equal "Parent Child GrandChild", grandchild.full_name
  end

  def test_should_raise_on_duplicate_naming
    context = Shoulda::Context::Context.new("DupContext", self.class) do
      should "dup" do; end
      should "dup" do; end
    end
    assert_raises Shoulda::Context::DuplicateTestError do
      context.build
    end
  end

  # Should statements

  def test_should_have_should_hashes_when_given_should_statements
    context = Shoulda::Context::Context.new("name", self.class) do
      should "be good" do; end
      should "another" do; end
    end

    names = context.shoulds.map {|s| s[:name]}
    assert_equal ["another", "be good"], names.sort
  end

  # setup and teardown

  def test_should_capture_setup_and_teardown_blocks
    context = Shoulda::Context::Context.new("name", self.class) do
      setup    do; "setup";    end
      teardown do; "teardown"; end
    end

    assert_equal "setup",    context.setup_blocks.first.call
    assert_equal "teardown", context.teardown_blocks.first.call
  end

  # building

  def test_should_create_shoulda_test_for_each_should_on_build
    context = Shoulda::Context::Context.new("name", self.class) do
      should "one" do; end
      should "two" do; end
    end
    context.expects(:create_test_from_should_hash).with(has_entry(:name => "one"))
    context.expects(:create_test_from_should_hash).with(has_entry(:name => "two"))
    context.build
  end

  def test_should_create_test_methods_on_build
    tu_class = self.class
    context = Shoulda::Context::Context.new("A Context", tu_class) do
      should "define the test" do; end
    end

    tu_class.
      expects(:define_method).
      with(
        build_expected_test_name("A Context should define the test. ").to_sym
      )
    context.build
  end

  def test_should_create_test_methods_on_build_when_subcontext
    tu_class = self.class
    context = Shoulda::Context::Context.new("A Context", tu_class) do
      context "with a child" do
        should "define the test" do; end
      end
    end

    tu_class.
      expects(:define_method).
      with(
        build_expected_test_name(
          "A Context with a child should define the test. "
        ).to_sym
      )
    context.build
  end

  # Test::Unit integration

  def test_should_create_a_new_context_and_build_it_on_test_case_context
    c = mock("context")
    c.expects(:build)
    Shoulda::Context::Context.expects(:new).with("foo", kind_of(Class)).returns(c)
    self.class.context "foo" do; end
  end

  def test_should_create_a_one_off_context_and_build_it_on_test_case_should
    s = mock("test")
    Shoulda::Context::Context.any_instance.expects(:should).with("rock", {}).returns(s)
    Shoulda::Context::Context.any_instance.expects(:build)
    self.class.should "rock" do; end
  end

  def test_should_create_a_one_off_context_and_build_it_on_test_case_should_eventually
    s = mock("test")
    Shoulda::Context::Context.any_instance.expects(:should_eventually).with("rock").returns(s)
    Shoulda::Context::Context.any_instance.expects(:build)
    self.class.should_eventually "rock" do; end
  end

  should "run a :before proc", :before => lambda { @value = "before" } do
    assert_equal "before", @value
  end

  context "A :before proc" do
    setup do
      assert_equal "before", @value
      @value = "setup"
    end

    should "run before the current setup", :before => lambda { @value = "before" } do
      assert_equal "setup", @value
    end
  end

  context "a before statement" do
    setup do
      assert_equal "before", @value
      @value = "setup"
    end

    before_should "run before the current setup" do
      @value = "before"
    end
  end

  context "A context" do
    setup do
      @value = "outer"
    end

    context "with a subcontext and a :before proc" do
      before = lambda do
        assert "outer", @value
        @value = "before"
      end
      should "run after the parent setup", :before => before do
        assert_equal "before", @value
      end
    end
  end

  def test_name
    name
  end

  def build_expected_test_name(value)
    if TEST_FRAMEWORK == "minitest"
      if value.is_a?(Regexp)
        Regexp.new("^test_: #{value.source}")
      else
        "test_: #{value}"
      end
    elsif value.is_a?(Regexp)
      Regexp.new("^test: #{value.source}")
    else
      "test: #{value}"
    end
  end

  # Minitest removed assert_nothing_raised a while back;
  # see here: <http://www.zenspider.com/ruby/2012/01/assert_nothing_tested.html>
  def assert_nothing_raised
    yield
  end
end

class RedTestarossaDriver; end

class RedTestarossaDriverTest < PARENT_TEST_CASE
  class DummyMatcher
    def description
      "fail to construct the proper test name with a 'should_not'"
    end

    def matches?(*)
      false
    end

    def failure_message_when_negated
      "dummy failure message"
    end
  end

  should "call Shoulda::Context::Context.new using the correct context name" do
    assert_equal "RedTestarossaDriver", @shoulda_context.name
  end

  should "see the name of the test case class as RedTestarossaDriverTest" do
    assert_equal "RedTestarossaDriverTest", self.class.name
  end

  should "include the correct context name in the full name of the test" do
    assert_match(
      build_expected_test_name(/RedTestarossaDriver/),
      test_name
    )
  end

  def test_should_property_construct_test_name_for_should_eventually
    context = Shoulda::Context::Context.new("whatever", self.class) do
      "this is just a placeholder"
    end

    Shoulda::Context::Context.
      expects(:new).
      with("RedTestarossaDriver", RedTestarossaDriverTest).
      returns(context)

    self.class.should_eventually("do something") {}
  end

  def test_should_property_construct_test_name_for_should_not
    context = Shoulda::Context::Context.new("whatever", self.class) do
      "this is just a placeholder"
    end

    Shoulda::Context::Context.
      expects(:new).
      with("RedTestarossaDriver", RedTestarossaDriverTest).
      returns(context)

    self.class.should_not(DummyMatcher.new)
  end

  private

  def test_name
    name
  end

  def build_expected_test_name(value)
    if TEST_FRAMEWORK == "minitest"
      if value.is_a?(Regexp)
        Regexp.new("^test_: #{value.source}")
      else
        "test_: #{value}"
      end
    elsif value.is_a?(Regexp)
      Regexp.new("^test: #{value.source}")
    else
      "test: #{value}"
    end
  end
end
