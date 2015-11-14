require 'duty/system'
require 'duty/worker'
require 'duty/command'

module Duty
  module Commands
    class Base
      def initialize(*args)
      end

      def call(system = Duty::System.new)
        @system = system
        worker.execute if valid?
        worker
      end

      def self.description
        "TODO: Describe your command by overwriting the `description` class method in your command class"
      end

      def usage
        <<-EOF
TODO: Describe how your command should be used by overwriting the `usage` method in your command class

usage: duty <your-command> <your-arguments>
        EOF
      end

      def valid?
        !usage.match /TODO/
      end

      private

      def worker
        return @worker if @worker
        @worker = Duty::Worker.new(commands)
      end

      def commands
        [
          how_to_command
        ]
      end

      def how_to_command
        command(
          'a_failing_command',
          'You have no commands defined yet. Define commands by overwriting the `commands` method in your command class. This method must contain a collection of `commands`. Use the `command` helper method to build a command. A command consists of two elements. First element is the shell command that should be executed. Second element is the description that will be presented in the CLI',
        )
      end

      def command(cmd, description)
        Duty::Command.new(cmd, description, @system)
      end
    end
  end
end
