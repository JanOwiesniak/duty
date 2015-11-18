require 'duty/commands/base'

module Duty
  module Commands
    class StartFeature < Duty::Commands::Base
      def self.description
        "Creates a new feature branch"
      end

      def initialize(*args)
        @name = [args].flatten.first
      end

      def usage
        <<-EOF
#{self.class.description}

Usage: duty start-feature <name>
        EOF
      end

      def valid?
        !!@name
      end

      private

      def commands
        [
          command('git checkout master', 'Checkout `master` branch'),
          command("git checkout -b 'feature/#{name}'", "Checkout `feature/#{name}` branch"),
          command("git push -u origin 'feature/#{name}'", "Push `feature/#{name}` branch to `origin`")
        ]
      end

      def name
        @name
      end
    end
  end
end