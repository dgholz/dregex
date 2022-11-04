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

  class AstDispatcher
    attr_reader :visitor
    def initialize(visitor)
      @visitor = visitor
    end

    def visit(node)
      case node
      when AstNode::Sequence
        visitor.enter_sequence(node)
        node.children.each { |node| visit node }
        visitor.exit_sequence(node)
      when AstNode::Literal
        visitor.on_literal(node)
      when AstNode::Any
        visitor.on_any(node)
      when AstNode::ZeroRepeat
        visitor.enter_zero_repeat(node)
        visit(node.node)
        visitor.exit_zero_repeat(node)
      when AstNode::OneRepeat
        visitor.enter_one_repeat(node)
        visit(node.node)
        visitor.exit_one_repeat(node)
      end
    end
  end
end
