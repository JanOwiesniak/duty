module Duty
  module Meta
    class Completion
      def initialize(cli, args)
        @registry = cli.registry
        @humanizer = Humanizer.new
        @input = args.join(" ").downcase
      end

      def to_s
        possible_completions
      end

      private

      attr_reader :registry, :humanizer

      def possible_completions
        matching_tasks.join("\n")
      end

      def matching_tasks
        humanized_tasks.select do |cmd|
          cmd.start_with?(@input)
        end
      end

      def humanized_tasks
        registry.plugins.map do |plugin|
          tasks_for(plugin)
        end.flatten
      end

      def tasks_for(plugin)
        plugin.tasks.map do |task_class|
          humanizer.task(task_class)
        end
      end
    end
  end
end
