require "forwardable"

module Dregex
  class Tokeniser
    extend Forwardable

    class Token
      attr_reader :value
      def initialize(value) @value = value end
      def to_s() inspect end
      def ==(other) other.class == self.class && other.value == self.value end
    end

    class Star < Token; def initialize() super("*") end; end
    class Plus < Token; def initialize() super("+") end; end
    class Dot < Token; def initialize() super(".") end; end
    class Char < Token; end

    attr_reader :pattern
    def initialize(pattern)
      @pattern = pattern
    end

    def enum
      Enumerator.new do |yielder|
        pattern.each_char do |char|
          case char
          when "*"
            yielder << Star.new
          when "+"
            yielder << Plus.new
          when "."
            yielder << Dot.new
          else
            yielder << Char.new(char)
          end
        end
      end
    end
    def_delegators :enum, :each

  end
end
