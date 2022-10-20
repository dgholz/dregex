require "spec_helper"

describe Dregex::Tokeniser do
  let(:tokeniser) { Dregex::Tokeniser.new(pattern) }
  let(:pattern) { "hel+o * wor.d" }

  it "produces a stream of tokens" do
    expect(tokeniser.each.to_a).wont_be_empty
    expect(tokeniser.each.to_a).must_equal [
      Dregex::Tokeniser::Char.new("h"),
      Dregex::Tokeniser::Char.new("e"),
      Dregex::Tokeniser::Char.new("l"),
      Dregex::Tokeniser::Plus.new,
      Dregex::Tokeniser::Char.new("o"),
      Dregex::Tokeniser::Char.new(" "),
      Dregex::Tokeniser::Star.new,
      Dregex::Tokeniser::Char.new(" "),
      Dregex::Tokeniser::Char.new("w"),
      Dregex::Tokeniser::Char.new("o"),
      Dregex::Tokeniser::Char.new("r"),
      Dregex::Tokeniser::Dot.new,
      Dregex::Tokeniser::Char.new("d"),
    ]
  end
end
