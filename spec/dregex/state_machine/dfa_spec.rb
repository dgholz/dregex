require "spec_helper"
require "dregex/state_machine/dfa"

describe Dregex::StateMachine::DFA do
  let(:dfa) { Dregex::StateMachine::DFA.new }
  it "comes up with a reasonable default for unnamed states" do
    new_state_name = dfa.create_state

    expect(new_state_name).must_equal :S0
  end

  it "keeps track of new states" do
    expect(dfa.states[:"am new"]).must_be_nil

    new_state_name = dfa.create_state "am new"

    expect(dfa.states[:"am new"]).wont_be_nil
  end

  it "normalises new state names to symbols" do
    new_state_name = dfa.create_state "am_test"

    expect(new_state_name).must_equal :am_test
  end

  it "can turn a list of states into nested hashes" do
    first = dfa.create_state
    second = dfa.create_state
    third = dfa.create_state

    first_state = dfa.states[first]
    second_state = dfa.states[second]
    third_state = dfa.states[third]

    first_state["a"] = second
    second_state["b"] = first
    first_state["c"] = third
    second_state["c"] = third

    dfa.start_state = first
    dfa.end_state = third

    state0 = {}
    state1 = {}
    state2 = {}
    state0["a"] = state1
    state1["b"] = state0
    state0["c"] = state2
    state1["c"] = state2
    state2[:end] = true

    expect(dfa.to_state_machine).must_equal state0
  end
end
