require 'set'

require 'dregex/state_machine/dfa'

module Dregex
  class StateMachine
    class NFA < FiniteAutomata

      def epsilon_transitions
        ets = states.keys.map do |state_name|
          e_transition = states[state_name][:empty]
          [
            state_name,
            Set.new([state_name, e_transition].compact)
          ]
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

    end
  end
end
