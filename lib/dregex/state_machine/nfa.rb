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
        # use powerset construction to convert NFA to DFA
        # a powerset state maps to multiple NFA states
        # and has all the transitions of its component states
        dfa = DFA.new
        powerset_to_dfa_state = Hash.new { |h,k| h[k] = dfa.create_state }

        e_reachable = epsilon_transitions
        start = epsilon_transitions[start_state]
        to_visit = [ start ]
        dfa.start_state = powerset_to_dfa_state[start]

        seen = Set.new
        while ! to_visit.empty?
          powerset_state = to_visit.shift
          seen.add powerset_state

          # make a regular state for the powerset state
          # check all transitions from states in the powerset state and group by transition
          regular_state = Hash.new { |h,k| h[k] = Set.new }
          powerset_state.each do |nfa_state_name|
            nfa_state = states[nfa_state_name]
            nfa_state.keys.each do |transition|
              next if transition == :empty
              nfa_state[transition].each do |reachable_state|
                regular_state[transition].merge e_reachable[reachable_state]
              end
            end
          end

          # now make DFA states for each group of transitioned states
          dfa_state = dfa.states[powerset_to_dfa_state[powerset_state]]
          dfa_state.merge! regular_state.transform_values { |v| powerset_to_dfa_state[v] }

          to_visit.push *(regular_state.values.to_set - seen)
        end

        powerset_to_dfa_state.each do |powerstates_of, dfa_state_name|
          next unless powerstates_of.intersect? end_states
          dfa.end_states.add dfa_state_name
        end
        dfa.to_state_machine
      end

    end
  end
end
