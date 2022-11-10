require 'fiber'

require 'dregex/ast_nodes'
require 'dregex/state_machine/nfa'

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
      extend Forwardable

      attr_reader :dispatcher, :nfa, :state
      attr_accessor :stay_on_current_state
      def_delegators :nfa, :states

      def initialize(dispatcher: nil, nfa: NFA.new)
        if dispatcher.nil?
          dispatcher = Dregex::AstDispatcher.new(self)
        end
        @nfa = nfa
        @dispatcher = dispatcher
        @state = nfa.create_state(:start)
        @stay_on_current_state = false
      end

      def build_from(ast)
        dispatcher.visit ast
        converted_states = nfa.convert_to_state_machine
        StateMachine.new converted_states[:start]
      end

      def on_sequence(node)
        Fiber.new do
          nfa.states[state][:end] = true
        end
      end

      def on_literal(node)
        traverse(node, next_state)
      end

      def on_any(node)
        traverse(node, next_state)
      end

      def on_zero_repeat(node)
        self.stay_on_current_state = true
      end

      def on_one_repeat(node)
        traverse(node.node, next_state)
        self.stay_on_current_state = true
      end

      def next_state
        if stay_on_current_state
          self.stay_on_current_state = false
          state
        else
          nfa.create_state
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
        nfa.states[state][value] = to_state
      end

    end
  end
end
