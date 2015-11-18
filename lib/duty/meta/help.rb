require 'duty/commands/registry'

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
  Usage: duty <command> [<args>]

  Commands:

  #{commands_with_description}
        EOF
      end

      def commands_with_description
        humanizer = Humanizer.new
        registry.all.map do |klass|
          "  " + humanizer.command(klass).ljust(20) + klass.description
        end.join("\n")
      end
    end
  end
end
