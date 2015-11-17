require 'duty/commands/registry'

module Duty
  module Meta
    class Completion
      def initialize(cli, args)
        @cli   = cli
        @input = args.join(" ").downcase
      end

      def to_s
        possible_completions
      end

      private

      def registry
        @cli.registry
      end

      def possible_completions
        matching_commands.join("\n")
      end

      def matching_commands
        humanized_commands.select do |cmd|
          cmd.start_with?(@input)
        end
      end

      def humanized_commands
        humanizer = Humanizer.new
        registry.all.map do |klass|
          humanizer.command(klass)
        end
      end
    end
  end
end
