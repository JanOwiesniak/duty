require 'duty/commands/base'

module Duty
  module Commands
    class NewFeature < Duty::Commands::Base
      def initialize(*args)
        @name = [args].flatten.first
      end

      def usage
        <<-msg
          Creates a new feature branch

          usage: duty new-feature <name>
        msg
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
