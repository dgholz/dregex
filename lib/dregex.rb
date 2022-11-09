require "dregex/version"
require "dregex/tokeniser"
require "dregex/parser"
require "dregex/state_machine"

module Dregex
  def Dregex.compile(pattern)
    tokens = Tokeniser.new(pattern).tap do |t|
      yield :tokens, t.each if block_given?
    end
    ast = Parser.new(tokens).ast.tap do |a|
      yield :ast, a if block_given?
    end
    builder = StateMachine::Builder.new
    state_machine = builder.build_from ast
    yield :states, builder.states if block_given?
    yield :state_machine, state_machine if block_given?
    state_machine
  end
end
