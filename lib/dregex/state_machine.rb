require 'dregex/ast_nodes'

module Dregex
  class StateMachine
    attr_reader :state

    def initialize(state)
      @state = state
    end

    def ==(other)
      other.class == self.class && other.state == state
    end

    def match(string)
      current = state
      string.each_char do |char|
        if current.has_key? char
          current = current[char]
        elsif current.has_key? :any
          current = current[:any]
        else
          return false
        end
      end
      current[:end] == true
    end

    class Builder
      attr_reader :state_machine, :state
      attr_accessor :stay_on_current_state

      def initialize(state={})
        @state = state
        @state_machine = StateMachine.new(state)
        @stay_on_current_state = false
      end

      def build_from(ast)
        Dregex::AstDispatcher.new(self).visit ast
        state_machine
      end

      def enter_sequence(node); end
      def exit_sequence(node)
        state[:end] = true
      end

      def on_literal(node)
        traverse(node, next_state)
      end

      def on_any(node)
        traverse(node, next_state)
      end

      def enter_zero_repeat(node)
        self.stay_on_current_state = true
      end
      def exit_zero_repeat(node); end

      def enter_one_repeat(node)
        traverse(node.node, next_state)
        self.stay_on_current_state = true
      end
      def exit_one_repeat(node); end

      def next_state
        if stay_on_current_state
          self.stay_on_current_state = false
          state
        else
          Hash.new
        end
      end

      def traverse(node, to_state)
        @state = add_edge(node, to_state)
      end

      def add_edge(node, to_state)
        value = case node
        when AstNode::Literal
          node.value
        when AstNode::Any
          :any
        end
        state[value] = to_state
      end
    end
  end
end
