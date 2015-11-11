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
        Worker.new(build_commands(system))
      end

      def build_commands(system)
        [
          Command.new('git checkout master', 'Checkout `master` branch', system),
          Command.new("git checkout -b 'feature/#{name}'", "Checkout `feature/#{name}` branch", system),
          Command.new("git push -u origin 'feature/#{name}'", "Push `feature/#{name}` branch to `origin`", system)
        ]
      end
    end
  end
end
