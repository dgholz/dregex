require 'slop'

require 'dregex'

module Dregex
  class CLI
    def self.run
      self.new.run
    end

    def run
      opts = Slop.parse(suppress_errors: true) do |option|
        option.banner = 'usage: dregex pattern <files>'
        option.separator 'Prints if lines match pattern. Uses STDIN if no files given'
        option.separator ''
        option.separator 'Flags:'
        option.on '--version', 'print the version' do
          puts Dregex::VERSION
          exit
        end
        option.on '--help', 'print this help' do
          puts option
          exit
        end
      end

      if opts.arguments.size == 1
        pattern = opts.arguments.shift
      end

      if pattern.nil?
        puts opts
        exit 1
      end
      matcher = Dregex::compile pattern

      ARGV.replace opts.arguments
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
