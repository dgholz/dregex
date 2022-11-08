require 'slop'

require 'dregex'

module Slop
  class InvalidChoice < Error; end
  class ChoiceOption < SymbolOption
    def call(value)
      choices = config.fetch(:choose_from, [])
      unless choices.include? value
        raise InvalidChoice.new("Invalid choice '#{value}'! Expected one of: »#{choices.join ", "}«")
      end
      super
    end
  end
end

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
        option.separator ''
        option.bool '--show-ast', 'print AST of pattern before creating state machine'
        option.bool '--show-tokens', 'print pattern tokens before parsing'
        option.bool '--show-state-machine', 'print compacted state machine'
        option.choice '--format', "which way to show internal data (plain). Defaults to 'plain'", default: :plain, choose_from: %w( plain )
      end

      if opts.arguments.size == 1
        pattern = opts.arguments.shift
      end

      if pattern.nil?
        puts opts
        exit 1
      end
      matcher = Dregex::compile pattern do |step, val|
        if opts[:"show_#{step}"]
          self.send(:"dump_#{step}", val, opts[:format])
        end
      end

      ARGV.replace opts.arguments
      ARGF.each_line do |line|
        if matcher.match(line.chomp)
          puts "Match"
        else
          puts "No match"
        end
      end
    end

    def dump_tokens(tokens, format)
      case format
      when :plain
        tokens.each { |t| puts t }
      else
        raise ArgumentError, "unknown dump format #{format}!"
      end
    end

    def dump_ast(ast, format)
      case format
      when :plain
       puts ast
      else
        raise ArgumentError, "unknown dump format #{format}!"
      end
    end

    def dump_state_machine(sm, format)
      case format
      when :plain
       puts sm.state
      else
        raise ArgumentError, "unknown dump format #{format}!"
      end
    end
  end
end
