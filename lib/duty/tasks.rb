module Duty
  module Tasks
    class Base
      ExecutionError = Class.new(RuntimeError)

      def initialize(arguments, view)
        @arguments = arguments
        @view = view
        @parallel = []
      end

      def run
        if !valid?
          task_explain
        else
          begin
            execute_in_thread
            task_success
          rescue ExecutionError
            task_failure
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

      def execute_in_thread
        Thread.new do
          execute
          @parallel.each {|thread| thread.join }
        end.join
      end

      def valid?
        !todo?(self.class.description) && !todo?(self.class.usage)
      end

      def todo?(string)
        string.match(/TODO/)
      end

      def task_explain
        @view.task_explain(self)
      end

      def task_success
        @view.task_success(self)
      end

      def task_failure
        @view.task_failure(self)
      end

      def command_success(command)
        @view.command_success(command)
      end

      def command_failure(command)
        @view.command_failure(command)
      end

      def parallel(&blk)
        @parallel << Thread.new(&blk)
      end

      def ruby(desc = 'Unknown ruby command', &blk)
        handle_errors(Ruby.run(desc, blk))
      end

      def sh(desc = 'Unknown shell command', &blk)
        handle_errors(Shell.run(desc, blk))
      end

      def handle_errors(command)
        if command.success?
          command_success(command)
        else
          command_failure(command)
          raise ExecutionError.new
        end
      end

      class Command
        def initialize(description, callable)
          @description = description 
          @callable = callable
          @success = false
          @error = nil
          @logger = []
        end

        def self.run(description, callable)
          new(description, callable).tap {|command| command.execute}
        end

        def success?
          @success
        end

        def description
          @description
        end

        def logger
          @logger
        end

        def error
          @error
        end
      end

      class Ruby < Command
        def execute
          begin
            @callable.call
            @success = true
          rescue Exception => e
            @error = "ERROR: #{e.inspect}"
          ensure
            @logger << summary 
            @logger << error
          end
        end

        private

        def summary
          "[RUBY] #{@callable.inspect}"
        end
      end

      class Shell < Command
        require 'open3'
        def execute
          if !cmd
            @success = true
            return
          end

          begin
            @stdout, @stderr, @status = Open3.capture3(cmd)
            @success = true if status.success?
          rescue Exception => e
            @error = "ERROR: #{e.inspect}"
          ensure
            @logger << summary 
            @logger << error
          end
        end

        private

        def summary
          [
            "[SHELL]",
            "COMMAND: #{cmd}",
            "DIR: #{dir}",
            "STDOUT: #{stdout}",
            "STDERR: #{stderr}",
            "STATUS: #{status}"
          ]
        end

        def stdout
          @stdout
        end

        def stderr
          @stderr
        end

        def status
          @status
        end

        def cmd
          @cmd ||= @callable.call
        end

        def dir
          Dir.pwd
        end
      end
    end
  end
end
