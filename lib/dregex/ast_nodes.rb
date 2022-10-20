require "forwardable"

module Dregex
  class AstNode
    def to_s() inspect end
    def ==(other)
      other.class == self.class
    end

    class Sequence < AstNode
      extend Forwardable

      attr_reader :children
      def initialize(*children)
        @children = children
      end

      def ==(other)
        super(other) && other.children == children
      end

      def_delegators :@children, :push, :pop, :[]
    end

    class ZeroRepeat < AstNode
      attr_reader :node
      def initialize(node)
        @node = node
      end

      def ==(other)
        super(other) && other.node == node
      end
    end

    OneRepeat = ZeroRepeat.dup

    class Any < AstNode
    end

    class Literal < AstNode
      attr_reader :value
      def initialize(value)
        @value = value
      end

      def ==(other)
        super(other) && other.value == value
      end
    end

  end
end
