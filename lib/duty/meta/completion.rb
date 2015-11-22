require 'duty/registry'

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
        matching_tasks.join("\n")
      end

      def matching_tasks
        humanized_tasks.select do |cmd|
          cmd.start_with?(@input)
        end
      end

      def humanized_tasks
        humanizer = Humanizer.new
        registry.all.map do |klass|
          humanizer.task(klass)
        end
      end
    end
  end
end
