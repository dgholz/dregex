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
        continuation = visitor.on_sequence(node)
        node.children.each { |node| visit node }
        continuation.resume if continuation.respond_to? :resume
      when AstNode::Literal
        visitor.on_literal(node)
      when AstNode::Any
        visitor.on_any(node)
      when AstNode::ZeroRepeat
        continuation = visitor.on_zero_repeat(node)
        visit(node.node)
        continuation.resume if continuation.respond_to? :resume
      when AstNode::OneRepeat
        continuation = visitor.on_one_repeat(node)
        visit(node.node)
        continuation.resume if continuation.respond_to? :resume
      end
    end
  end
end
