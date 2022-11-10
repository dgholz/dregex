require "spec_helper"

describe Dregex::StateMachine do
  let(:tokeniser) { Dregex::Tokeniser.new(pattern) }
  let(:pattern) { "foo" }
  let(:parser) { Dregex::Parser.new(tokeniser) }
  let(:builder) { Dregex::StateMachine::Builder.new }
  let(:state_machine) { builder.build_from parser.ast }

  it "matches plain patterns" do
    expect(state_machine.match("foo")).must_equal true
    expect(state_machine.match("food")).must_equal false
  end

  describe "patterns with wildcards" do
    let(:pattern) { "b.r" }
    it "matches slighly more complicated patterns" do
      expect(state_machine.match("bar")).must_equal true
      expect(state_machine.match("bear")).must_equal false
      expect(state_machine.match("bor")).must_equal true
    end
  end

  describe "patterns with repeats" do
    let(:pattern) { "baz*" }
    xit "matches patterns with repeats" do
      expect(state_machine.match("foo")).must_equal false
      expect(state_machine.match("ba")).must_equal true
      expect(state_machine.match("baz")).must_equal true
      expect(state_machine.match("bazzz")).must_equal true
      expect(state_machine.match("bazzza")).must_equal false
    end
  end

  describe "patterns with the other kind of repeats" do
    let(:pattern) { "qu+x" }
    xit "matches patterns with repeats" do
      expect(state_machine.match("qx")).must_equal false
      expect(state_machine.match("qux")).must_equal true
      expect(state_machine.match("quux")).must_equal true
      expect(state_machine.match("quuux")).must_equal true
      expect(state_machine.match("quuuxy")).must_equal false
    end
  end
end
