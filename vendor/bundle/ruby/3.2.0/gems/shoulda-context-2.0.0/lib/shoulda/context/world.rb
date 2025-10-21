module Shoulda
  module Context
    class << self
      def contexts # :nodoc:
        @contexts ||= []
      end
      attr_writer :contexts

      def current_context # :nodoc:
        self.contexts.last
      end

      def add_context(context) # :nodoc:
        self.contexts.push(context)
      end

      def remove_context # :nodoc:
        self.contexts.pop
      end
    end
  end
end
