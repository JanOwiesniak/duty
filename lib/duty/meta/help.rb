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
        registry.all.map do |klass|
          "  " + command_name_for(klass).ljust(20) + klass.description
        end.join("\n")
      end

      def command_name_for(klass)
        klass.to_s.
          gsub("#{Commands::Registry::COMMAND_NAMESPACE}::", '').
          gsub(/([A-Z])/, '-\1').
          split('-').
          reject(&:empty?).
          map(&:downcase).
          join('-')
      end
    end
  end
end
