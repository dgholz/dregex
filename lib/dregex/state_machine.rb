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

      attr_reader :current_state_name, :dispatcher, :nfa
      def_delegators :nfa, :states

      def initialize(dispatcher: nil, nfa: NFA.new)
        if dispatcher.nil?
          dispatcher = Dregex::AstDispatcher.new(self)
        end
        @nfa = nfa
        @dispatcher = dispatcher
        @current_state_name = nfa.create_state
        nfa.start_state = @current_state_name
      end

      def current_state
        nfa.states[current_state_name]
      end

      def current_state=(value)
        @current_state_name = value
      end

      def build_from(ast)
        dispatcher.visit ast
        nfa.end_states.add current_state_name
        converted_states = nfa.to_state_machine
        StateMachine.new converted_states
      end

      def on_sequence(node); end

      def on_literal(node)
        new = nfa.create_state
        current_state[node.value].add new
        self.current_state = new
      end

      def on_any(node)
        new = nfa.create_state
        current_state[:any].add new
        self.current_state = new
      end

      def on_zero_repeat(node)
        back_to = current_state_name

        Fiber.new do
          self.current_state[:empty].add back_to
          new = nfa.create_state
          nfa.states[back_to][:empty].add new
          self.current_state = new
        end
      end

      def on_one_repeat(node)
        dispatcher.visit node.node
        on_zero_repeat(node)
      end

    end
  end
end
