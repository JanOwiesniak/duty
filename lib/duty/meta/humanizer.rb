module Duty
  module Meta
    class Humanizer
      def command(klass)
        klass.to_s.
          gsub("#{command_namespace}::", '').
          gsub(/([A-Z])/, '-\1').
          split('-').
          reject(&:empty?).
          map(&:downcase).
          join('-')
      end

      private

      def command_namespace
        Commands::Registry::COMMAND_NAMESPACE
      end
    end
  end
end
