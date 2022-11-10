module Dregex
  class StateMachine
    class NFA
      attr_reader :states, :state_namer
      def initialize(state_namer: nil)
        if state_namer.nil?
          state_namer = _build_state_namer
        end
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

      def create_state(new_state_name=nil, state_list: self.states)
        if new_state_name.nil?
          new_state_name = state_namer.next
        end
        new_state_name = new_state_name.to_sym
        new_state = {}
        state_list[new_state_name] = new_state
        new_state_name
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
