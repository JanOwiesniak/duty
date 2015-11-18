module Duty
  module Tasks
    class Test < Duty::Tasks::Base
      def initialize(*args)
        @given_arg = [args].flatten.first
      end

      def self.description
        "This is a test task"
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
            shell('pwd','Done something great'),
            shell('pwd','This was even greater')
          ]
        else
          [
            shell('this_wont_work','Done something great'),
            shell('pwd','This was even greater')
          ]
        end
      end
    end
  end
end
