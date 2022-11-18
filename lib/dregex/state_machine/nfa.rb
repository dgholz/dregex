require 'set'

require 'dregex/state_machine/dfa'

module Dregex
  class StateMachine
    class NFA < FiniteAutomata

      def _build_new_state
        Hash.new { |h,k| h[k] = Set.new }
      end

      def epsilon_transitions
        ets = states.keys.map do |state_name|
          transition = Set.new
          transition.add state_name
          e_transition = states[state_name][:empty]
          transition.merge e_transition if !e_transition.nil?
          [state_name, transition]
        end.to_h

        ets.each do |state_name, e_reachable_states|
          seen = [ state_name ].to_set
          to_visit = e_reachable_states.to_a
          while ! to_visit.empty?
            look_at = to_visit.shift
            seen.add look_at
            ets[state_name].add look_at
            to_visit.push *(ets[look_at] - seen).to_a
          end
        end
        ets
      end

      def to_state_machine
        convert = states.transform_values do |state|
          state.clone
        end

        convert.each do |state_name, state|
          state.each do |transition, next_states|
            next_state_name = next_states.to_a.first
            state[transition] = convert[next_state_name]
          end
        end

        convert.values_at(*end_states.to_a).each { |s| s[:end] = true }
        convert[start_state]
      end

    end
  end
end
