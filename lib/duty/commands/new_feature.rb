module Duty
  module Commands
    class NewFeature
      class System
        def call(cmd)
          Open3.capture3(cmd)
        end
      end

      def initialize(name = nil)
        @name = name
      end

      def usage
        _usage.gsub(/^ +/,'')
      end

      def call(system = System.new)
        executor = build_executer(system)
        executor.execute if name
        executor
      end

      private

      def name
        @name
      end

      def _usage
        <<-msg
          Creates a new feature branch

          usage: duty new-feature <name>
        msg
      end

      def build_executer(system)
        CommandExecutor.new(build_commands(system))
      end

      def build_commands(system)
        [
          Command.new('git checkout master', 'Checkout `master` branch', system),
          Command.new("git checkout -b 'feature/#{name}'", "Checkout `feature/#{name}` branch", system),
          Command.new("git push -u origin 'feature/#{name}'", "Push `feature/#{name}` branch to `origin`", system)
        ]
      end

      class CommandExecutor
        def initialize(commands)
          @commands = commands
          @executed = []
        end

        def execute
          @commands.each do |command|
            command.execute
            @executed << command
          end
        end

        def executed
          @executed
        end
      end

      class Command
        def initialize(cmd, desciption, system)
          @cmd = cmd
          @desciption = desciption
          @system = system
          @executed = false
          @error = nil
        end

        def cmd
          @cmd
        end

        def pwd
          Dir.pwd
        end

        def describe
          @desciption
        end

        def executed?
          @executed
        end

        def error?
          !!error
        end

        def error
          if @executed == false
            'Not executed'
          else
            @error
          end
        end

        def execute
          @executed = true
          stdout, stderr, status = @system.call(@cmd)
          @error = stderr if status != 0
        end
      end
    end
  end
end
