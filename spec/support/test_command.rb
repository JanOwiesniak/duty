module Duty
  module Commands
    class Test < Duty::Commands::Base
      def initialize(*args)
        @given_arg = [args].flatten.first
      end

      def self.description
        "This is a test command"
      end

      def usage
        <<-EOF
#{self.class.description}

Usage: duty test [<args>]
        EOF
      end

      def valid?
        !!@given_arg
      end

      def commands
        if @given_arg == 'success'
          [
            command('pwd','Done something great'),
            command('pwd','This was even greater')
          ]
        else
          [
            command('this_wont_work','Done something great'),
            command('pwd','This was even greater')
          ]
        end
      end
    end
  end
end
