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
    StateMachine::Builder.new.build_from ast
  end
end
