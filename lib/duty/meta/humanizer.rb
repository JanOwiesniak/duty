module Duty
  module Meta
    class Humanizer
      def task(klass)
        klass.to_s.
          gsub("#{task_namespace}::", '').
          gsub(/([A-Z])/, '-\1').
          split('-').
          reject(&:empty?).
          map(&:downcase).
          join('-')
      end

      private

      def task_namespace
        Registry::COMMAND_NAMESPACE
      end
    end
  end
end
