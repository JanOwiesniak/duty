module Duty
  module Commands
    class Test
      ExecutionError = Class.new(RuntimeError)

      def initialize(arguments, view)
        @given_arg = arguments[0]
        @view = view
      end

      def self.description
        "This is a test command"
      end

      def run
        unless valid?
          add_message usage
        else
          begin
            execute
          rescue ExecutionError
          end
        end
      end

      private

      def add_message(msg)
        @view.add_message(msg)
      end

      def add_success(msg)
        @view.add_success(msg)
      end

      def add_failure(msg)
        @view.add_failure(msg)
      end

      def valid?
        !!@given_arg
      end

      def usage
        <<-EOF
#{self.class.description}

Usage: duty test [<args>]
        EOF
      end

      def execute
        if @given_arg == 'shell'
          sh('pwd','First shell command')
          sh('boom','Second shell command')
          sh('pwd','Third shell command')
        else
          ruby(Proc.new{},'First ruby command')
          ruby(Proc.new{ raise RuntimeError.new },'Second ruby command')
          ruby(Proc.new{},'Third ruby command')
        end
      end

      def ruby(callable, desc)
        ruby = Ruby.new(callable)
        ruby.execute
        handle_errors(ruby, desc)
      end

      def sh(cmd, desc)
        shell = Shell.new(cmd)
        shell.execute
        handle_errors(shell, desc)
      end

      def handle_errors(execution, desc)
        if execution.success?
          add_success desc
        else
          add_failure desc
          raise ExecutionError.new
        end
      end

      class Ruby
        def initialize(callable)
          @callable = callable
          @success = false
        end

        def success?
          @success
        end

        def execute
          @callable.call
          @success = true
        rescue
        end
      end

      class Shell
        require 'open3'
        def initialize(cmd)
          @cmd = cmd 
          @success = false
        end

        def success?
          @success
        end

        def execute
          begin
            stdout, stderr, status = Open3.capture3(@cmd)
            @success = true if status.success?
          rescue Errno::ENOENT
            @success = false
          end
        end
      end
    end
  end
end
