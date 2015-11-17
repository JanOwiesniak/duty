require 'duty/commands/base'

module Duty
  module Commands
    class NewFeature < Duty::Commands::Base
      def self.description
        "Creates a new feature branch"
      end

      def initialize(*args)
        @name = [args].flatten.first
      end

      def usage
        <<-EOF
#{self.class.description}

Usage: duty new-feature <name>
        EOF
      end

      def valid?
        !!@name
      end

      private

      def commands
        [
          shell('git checkout master', 'Checkout `master` branch'),
          shell("git checkout -b 'feature/#{name}'", "Checkout `feature/#{name}` branch"),
          shell("git push -u origin 'feature/#{name}'", "Push `feature/#{name}` branch to `origin`")
        ]
      end

      def name
        @name
      end
    end
  end
end
