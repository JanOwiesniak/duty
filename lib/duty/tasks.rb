module Duty
  module Tasks
    class Base
      ExecutionError = Class.new(RuntimeError)

      def initialize(arguments, view)
        @arguments = arguments
        @view = view
      end

      def run
        unless valid?
          add_message self.class.description
          add_message self.class.usage
        else
          begin
            execute
            add_success("#{self.class.name} task executed")
          rescue ExecutionError
            add_failure("#{self.class.name} task aborted")
          end
        end
      end

      def self.name
        self.to_s.split('::').last
      end

      def self.description
        "TODO: Describe your task by overwriting `self.description`"
      end

      def self.usage
        "TODO: Explain your task by overwriting `self.usage`"
      end

      def execute
        ruby(Proc.new{},'Describe your task')
        ruby(Proc.new{},'Explain your task')
        ruby(Proc.new{ raise ExecutionError.new },'TODO: Implement your task by overwriting `execute`')
      end

      private

      def valid?
        !todo?(self.class.description) && !todo?(self.class.usage)
      end

      def todo?(string)
        string.match(/TODO/)
      end

      def add_message(msg)
        @view.add_message(msg)
      end

      def add_success(msg)
        @view.add_success(msg)
      end

      def add_failure(msg)
        @view.add_failure(msg)
      end

      def ruby(desc = '', &blk)
        ruby = Ruby.new(blk)
        ruby.execute
        handle_errors(ruby, desc)
      end

      def sh(desc = '', &blk)
        shell = Shell.new(blk)
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
        def initialize(blk)
          @cmd = blk.call 
          @success = false
        end

        def success?
          @success
        end

        def execute
          begin
            if @cmd
              stdout, stderr, status = Open3.capture3(@cmd)
              @success = true if status.success?
            else
              @success = true
            end
          rescue Errno::ENOENT
            @success = false
          end
        end
      end
    end
  end
end
