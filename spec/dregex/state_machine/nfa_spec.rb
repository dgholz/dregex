require "spec_helper"
require "set"

describe Dregex::StateMachine::NFA do
  let(:tokeniser) { Dregex::Tokeniser.new(pattern) }
  let(:pattern) { "foo" }
  let(:parser) { Dregex::Parser.new(tokeniser) }
  let(:builder) { Dregex::StateMachine::Builder.new }
  let(:nfa) { builder.build_from parser.ast; builder.nfa }

  describe "#epsilon_transitions" do
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
