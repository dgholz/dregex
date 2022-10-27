require "spec_helper"
require "set"

describe Dregex::StateMachine::NFA do
  let(:nfa) { Dregex::StateMachine::NFA.new }
  it "comes up with a reasonable default for unnamed states" do
    new_state_name = nfa.create_state

    expect(new_state_name).must_equal :S0
  end

  it "keeps track of new states" do
    expect(nfa.states[:"am new"]).must_be_nil

    new_state_name = nfa.create_state "am new"

    expect(nfa.states[:"am new"]).wont_be_nil
  end

  it "normalises new state names to symbols" do
    new_state_name = nfa.create_state "am_test"

    expect(new_state_name).must_equal :am_test
  end

  it "can turn a list of states into nested hashes" do
    first = nfa.create_state
    second = nfa.create_state
    third = nfa.create_state

    first_state = nfa.states[first]
    second_state = nfa.states[second]
    third_state = nfa.states[third]

    first_state["a"] = second
    second_state["b"] = first
    first_state["c"] = third
    second_state["c"] = third

    nfa.start_state = first
    nfa.end_state = third

    state0 = {}
    state1 = {}
    state2 = {}
    state0["a"] = state1
    state1["b"] = state0
    state0["c"] = state2
    state1["c"] = state2
    state2[:end] = true

    expect(nfa.to_state_machine).must_equal state0
  end

  describe "#epsilon_transitions" do
    let(:tokeniser) { Dregex::Tokeniser.new(pattern) }
    let(:pattern) { "foo" }
    let(:parser) { Dregex::Parser.new(tokeniser) }
    let(:builder) { Dregex::StateMachine::Builder.new }
    let(:nfa) { builder.build_from parser.ast; builder.nfa }
    let(:pattern) { "fo*ot+" }
    it "tracks which states can be reached via epsilon transitions" do
      expect(nfa.epsilon_transitions).must_equal({
        S0: Set.new([:S0]),
        S1: Set.new([:S1, :S3]),
        S2: Set.new([:S1, :S2, :S3]),
        S3: Set.new([:S3]),
        S4: Set.new([:S4]),
        S5: Set.new([:S5, :S7]),
        S6: Set.new([:S5, :S6, :S7]),
        S7: Set.new([:S7]),
      })
    end
  end
end
