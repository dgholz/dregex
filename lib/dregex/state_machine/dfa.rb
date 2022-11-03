module Dregex
  class StateMachine
    class FiniteAutomata

      attr_reader :states, :state_namer
      attr_accessor :start_state, :end_state
      def initialize(state_namer: nil)
        if state_namer.nil?
          state_namer = _build_state_namer
        end
        @start_state = nil
        @end_state = nil
        @state_namer = state_namer
        @states = {}
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

      def create_state(new_state_name=nil)
        if new_state_name.nil?
          new_state_name = state_namer.next
        end
        new_state_name = new_state_name.to_sym
        new_state = _build_new_state
        states[new_state_name] = new_state
        new_state_name
      end

      def _build_new_state
        Hash.new
      end

      def to_state_machine
        convert = states.transform_values do |state|
          state.clone
        end

        convert.each do |state_name, state|
          state.each do |transition, next_state_name|
            state[transition] = convert[next_state_name]
          end
        end

        convert[end_state][:end] = true
        convert[start_state]
      end

    end

    class DFA < FiniteAutomata; end
  end
end
