require 'fiber'

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
      attr_reader :state, :states, :state_namer, :dispatcher
      attr_accessor :stay_on_current_state

      def initialize(state_namer: nil, dispatcher: nil)
        if state_namer.nil?
          state_namer = _build_state_namer
        end
        if dispatcher.nil?
          dispatcher = Dregex::AstDispatcher.new(self)
        end
        @state_namer = state_namer
        @state = :start
        @states = { @state => {} }
        @dispatcher = dispatcher
        @stay_on_current_state = false
      end

      def _build_state_namer
        i = 0
        Enumerator.new do |yielder|
          while(1)
            yielder << "S#{i}"
            i += 1
          end
        end
      end

      def build_from(ast)
        dispatcher.visit ast
        converted_states = convert_to_state_machine
        StateMachine.new converted_states[:start]
      end

      def on_sequence(node)
        Fiber.new do
          states[state][:end] = true
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
          new = state_namer.next
          states[new] = Hash.new
          new
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
        states[state][value] = to_state
      end

      def convert_to_state_machine
        convert = states.keys.to_h do |state_name|
          [state_name, states[state_name].dup]
        end
        convert.each do |state_name, state|
          state.each do |transition, next_state_name|
            next unless convert.has_key? next_state_name
            state[transition] = convert[next_state_name]
          end
        end
        convert
      end

    end
  end
end
