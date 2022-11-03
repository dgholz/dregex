require "spec_helper"

describe Dregex::StateMachine::Builder do
  let(:tokeniser) { Dregex::Tokeniser.new(pattern) }
  let(:pattern) { "foo" }
  let(:parser) { Dregex::Parser.new(tokeniser) }
  let(:builder) { Dregex::StateMachine::Builder.new }

  it "builds a state machine" do
    expect(builder.build_from parser.ast).must_equal Dregex::StateMachine.new(
      {
        "f" => {
          "o" => {
            "o" => {
              :end => true,
            },
          },
        },
      }
    )
  end

  describe "when pattern has repeats" do
    let(:pattern) { "foo*" }
    it "builds a state machine" do
      repeated_state = { :empty => { :end => true } }
      repeated_state["o"] = { :empty => repeated_state }

      expect(builder.build_from parser.ast).must_equal Dregex::StateMachine.new(
        {
          "f" => {
            "o" => repeated_state,
          },
        }
      )
    end
  end

  describe "when pattern has the other kind of repeats" do
    let(:pattern) { "qu+x" }
    it "builds a state machine" do
      repeated_state = {}
      repeated_state["u"] = { :empty => repeated_state }
      repeated_state[:empty] = { "x" => { :end => true } }

      expect(builder.build_from parser.ast).must_equal Dregex::StateMachine.new(
        {
          "q" => {
            "u" => repeated_state,
          },
        }
      )
    end
  end

  describe "when pattern has wildcards" do
    let(:pattern) { "b.r" }
    it "builds a state machine" do
      expect(builder.build_from parser.ast).must_equal Dregex::StateMachine.new(
        {
          "b" => {
            :any => {
              "r" => {
                :end => true,
              },
            },
          },
        }
      )
    end
  end
end
