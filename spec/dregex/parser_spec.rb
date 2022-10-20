require "spec_helper"

describe Dregex::Parser do
  let(:tokeniser) { Dregex::Tokeniser.new(pattern) }
  let(:pattern) { "hel+o * wor.d" }
  let(:parser) { Dregex::Parser.new(tokeniser) }

  it "returns an AST" do
    expect(parser.to_ast).must_equal Dregex::AstNode::Sequence.new(
      Dregex::AstNode::Literal.new("h"),
      Dregex::AstNode::Literal.new("e"),
      Dregex::AstNode::OneRepeat.new(
        Dregex::AstNode::Literal.new("l"),
      ),
      Dregex::AstNode::Literal.new("o"),
      Dregex::AstNode::ZeroRepeat.new(
        Dregex::AstNode::Literal.new(" "),
      ),
      Dregex::AstNode::Literal.new(" "),
      Dregex::AstNode::Literal.new("w"),
      Dregex::AstNode::Literal.new("o"),
      Dregex::AstNode::Literal.new("r"),
      Dregex::AstNode::Any.new,
      Dregex::AstNode::Literal.new("d"),
    )
  end

  describe "given an invalid pattern" do
    let(:pattern) { "+oops" }

    it "raises a syntax error about the pattern" do
      expect { parser.to_ast }.must_raise Dregex::ParserError, /saw '+' with nothing before it/
    end
  end

  describe "given a slightly-different invalid pattern" do
    let(:pattern) { "*its my first day" }

    it "raises a syntax error about the pattern" do
      expect { parser.to_ast }.must_raise Dregex::ParserError, /saw '*' with nothing before it/
    end
  end
end
