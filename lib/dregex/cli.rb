require 'slop'

require 'dregex'

module Dregex
  class CLI
    def self.run
      pattern = ARGV.shift
      matcher = Dregex::compile pattern

      ARGF.each_line do |line|
        if matcher.match(line.chomp)
          puts "Match"
        else
          puts "No match"
        end
      end
    end
  end
end
