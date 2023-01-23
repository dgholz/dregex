require "spec_helper"

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

    state0 = {}
    state1 = {}
    state2 = {}
    state0["a"] = state1
    state1["b"] = state0
    state0["c"] = state2
    state1["c"] = state2

    expect(nfa.convert_to_state_machine).must_equal({
      first => state0,
      second => state1,
      third => state2,
    })
  end
end
