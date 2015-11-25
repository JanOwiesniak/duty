module Duty
  module Meta
    class Help
      def initialize(cli)
        @registry = cli.registry
        @humanizer = Humanizer.new
      end

      def to_s
        usage
      end

      private

      attr_reader :registry, :humanizer

      def usage
        msg = <<-EOF
Usage: duty <task> [<args>]

Tasks:

#{plugins}
        EOF
      end

      def plugins
        registry.plugins.map do |plugin|
          [namespace_for(plugin), tasks_for(plugin)].join("\n")
        end.join("\n")
      end

      def namespace_for(plugin)
        "[" + plugin.namespace + "]"
      end

      def tasks_for(plugin)
        plugin.tasks.map do |task_class|
          [" • ", humanizer.task(task_class).ljust(20), task_class.description].join
        end.join("\n")
      end
    end
  end
end
