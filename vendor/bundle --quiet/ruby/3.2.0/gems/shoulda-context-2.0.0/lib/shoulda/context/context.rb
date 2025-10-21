module Shoulda
  module Context
    class Context # :nodoc:
      attr_accessor :name               # my name
      attr_accessor :parent             # may be another context, or the original test::unit class.
      attr_accessor :subcontexts        # array of contexts nested under myself
      attr_accessor :setup_blocks       # blocks given via setup methods
      attr_accessor :teardown_blocks    # blocks given via teardown methods
      attr_accessor :shoulds            # array of hashes representing the should statements
      attr_accessor :should_eventuallys # array of hashes representing the should eventually statements

      # accessor with cache
      def subject_block
        return @subject_block if @subject_block
        parent.subject_block
      end
      attr_writer :subject_block

      def initialize(name, parent, &blk)
        Shoulda::Context.add_context(self)
        self.name               = name
        self.parent             = parent
        self.setup_blocks       = []
        self.teardown_blocks    = []
        self.shoulds            = []
        self.should_eventuallys = []
        self.subcontexts        = []
        self.subject_block      = nil

        if block_given?
          merge_block(&blk)
        else
          merge_block { warn "  * WARNING: Block missing for context '#{full_name}'" }
        end
        Shoulda::Context.remove_context
      end

      def merge_block(&blk)
        if self.respond_to?(:instance_exec)
          self.instance_exec(&blk)
        else
          # deprecated in Rails 4.x
          blk.bind(self).call
        end
      end

      def context(name, &blk)
        self.subcontexts << Context.new(name, self, &blk)
      end

      def setup(&blk)
        self.setup_blocks << blk
      end

      def teardown(&blk)
        self.teardown_blocks << blk
      end

      def should(name_or_matcher, options = {}, &blk)
        if name_or_matcher.respond_to?(:description) && name_or_matcher.respond_to?(:matches?)
          name = name_or_matcher.description
          blk = lambda { assert_accepts name_or_matcher, subject }
        else
          name = name_or_matcher
        end

        if blk
          self.shoulds << { :name => name, :before => options[:before], :block => blk }
        else
          self.should_eventuallys << { :name => name }
        end
      end

      def should_not(matcher)
        name = matcher.description
        blk = lambda { assert_rejects matcher, subject }
        self.shoulds << { :name => "not #{name}", :block => blk }
      end

      def should_eventually(name, &blk)
        self.should_eventuallys << { :name => name, :block => blk }
      end

      def subject(&block)
        self.subject_block = block
      end

      def full_name
        parent_name = parent.full_name if am_subcontext?
        return [parent_name, name].join(" ").strip
      end

      def am_subcontext?
        parent.is_a?(self.class) # my parent is the same class as myself.
      end

      def test_unit_class
        am_subcontext? ? parent.test_unit_class : parent
      end

      def test_methods
        @test_methods ||= Hash.new { |h,k|
          h[k] = Hash[k.instance_methods.map { |n| [n, true] }]
        }
      end

      def create_test_from_should_hash(should)
        test_name = build_test_name_from(should)

        if test_methods[test_unit_class][test_name.to_s]
          raise Shoulda::Context::DuplicateTestError.new(
            "'#{test_name}' is defined more than once."
          )
        end

        test_methods[test_unit_class][test_name.to_s] = true
        file, line_no = should[:block].source_location

        # Ruby doesn't know that we are referring to this variable inside of the
        # eval, so it will emit a warning that it's "assigned but unused".
        # However, making a double assignment places `context` on the right hand
        # side of the assignment, thereby putting it into use.
        context = context = self

        test_unit_class.class_eval <<-end_eval, file, line_no
          define_method test_name do
            @shoulda_context = context
            begin
              context.run_parent_setup_blocks(self)
              if should[:before]
                instance_exec(&should[:before])
              end
              context.run_current_setup_blocks(self)
              instance_exec(&should[:block])
            ensure
              context.run_all_teardown_blocks(self)
            end
          end
        end_eval
      end

      def build_test_name_from(should)
        [
          test_name_prefix,
          full_name,
          "should",
          "#{should[:name]}. "
        ].flatten.join(' ').to_sym
      end

      def run_all_setup_blocks(binding)
        run_parent_setup_blocks(binding)
        run_current_setup_blocks(binding)
      end

      def run_parent_setup_blocks(binding)
        self.parent.run_all_setup_blocks(binding) if am_subcontext?
      end

      def run_current_setup_blocks(binding)
        setup_blocks.each do |setup_block|
          if binding.respond_to?(:instance_exec)
            binding.instance_exec(&setup_block)
          else
            # deprecated in Rails 4.x
            setup_block.bind(binding).call
          end
        end
      end

      def run_all_teardown_blocks(binding)
        teardown_blocks.reverse.each do |teardown_block|
          if binding.respond_to?(:instance_exec)
            binding.instance_exec(&teardown_block)
          else
            # deprecated in Rails 4.x
            teardown_block.bind(binding).call
          end
        end
        self.parent.run_all_teardown_blocks(binding) if am_subcontext?
      end

      def print_should_eventuallys
        should_eventuallys.each do |should|
          test_name = [full_name, "should", "#{should[:name]}. "].flatten.join(' ')
          puts "  * DEFERRED: " + test_name
        end
      end

      def build
        shoulds.each do |should|
          create_test_from_should_hash(should)
        end

        subcontexts.each { |context| context.build }

        print_should_eventuallys
      end

      def test_name_prefix
        if defined?(Minitest)
          'test_:'
        else
          'test:'
        end
      end

      def method_missing(method, *args, &blk)
        test_unit_class.send(method, *args, &blk)
      end
    end

    class DuplicateTestError < RuntimeError; end
  end
end

