require "dregex/version"
require "dregex/tokeniser"
require "dregex/parser"
require "dregex/state_machine"

module Dregex
  def Dregex.compile(pattern)
    ast = Parser.new(Tokeniser.new(pattern)).to_ast
    StateMachine::Builder.new.build_from ast
  end
end
