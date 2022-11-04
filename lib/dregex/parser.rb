require "dregex/tokeniser"
require "dregex/ast_nodes"

module Dregex
  class ParserError < Exception; end
  class Parser

    attr_reader :tokens
    def initialize(tokens)
      @tokens = tokens
    end

    def ast
      @ast ||= _build_ast
    end

    def _build_ast
      ast = AstNode::Sequence.new
      tokens.each do |tok|
        case tok
        when Tokeniser::Star
          prev = ast.pop
          raise ParserError.new("saw '*' with nothing before it!") if prev.nil?
          ast.push AstNode::ZeroRepeat.new(prev)
        when Tokeniser::Plus
          prev = ast.pop
          raise ParserError.new("saw '+' with nothing before it!") if prev.nil?
          ast.push AstNode::OneRepeat.new(prev)
        when Tokeniser::Dot
          ast.push AstNode::Any.new
        when Tokeniser::Char
          ast.push AstNode::Literal.new(tok.value)
        else
          raise ParserError.new("unknown token #{tok}!")
        end
      end
      ast
    end

  end
end
