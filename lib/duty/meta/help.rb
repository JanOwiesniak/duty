module Duty
  module Meta
    class Help
      def initialize(cli)
        @cli = cli
      end

      def to_s
        usage
      end

      private

      def registry
        @cli.registry
      end

      def usage
        msg = <<-EOF
  Usage: duty <task> [<args>]

  Tasks:

  #{tasks_with_description}
        EOF
      end

      def tasks_with_description
        humanizer = Humanizer.new
        registry.all.map do |klass|
          "  " + humanizer.task(klass).ljust(20) + klass.description
        end.join("\n")
      end
    end
  end
end
