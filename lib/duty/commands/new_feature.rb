require 'duty/system'
require 'duty/worker'
require 'duty/command'

module Duty
  module Commands
    class NewFeature
      def initialize(name = nil)
        @name = name
      end

      def usage
        _usage.gsub(/^ +/,'')
      end

      def call(system = Duty::System.new)
        worker = build_worker(system)
        worker.execute if name
        worker
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

      def build_worker(system)
        Duty::Worker.new(build_commands(system))
      end

      def build_commands(system)
        [
          build_command('git checkout master', 'Checkout `master` branch', system),
          build_command("git checkout -b 'feature/#{name}'", "Checkout `feature/#{name}` branch", system),
          build_command("git push -u origin 'feature/#{name}'", "Push `feature/#{name}` branch to `origin`", system)
        ]
      end

      def build_command(cmd, description, system)
        Duty::Command.new(cmd, description, system)
      end
    end
  end
end
